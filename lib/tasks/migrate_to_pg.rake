namespace :migrate_to_pg do
  desc 'Migrate Config from Mongo to Postgres'
  task config: :environment do
    pg = Config
    mongo = MongoConfig
    migrate_model(pg, mongo)
  end

  task event: :environment do
    pg = Event
    mongo = MongoEvent

    extra_transform = Proc.new do |attrs, obj|
      event_type_mapping = {
        "Reached patient" => :reached_patient,
        "Couldn't reach patient" => :couldnt_reach_patient,
        "Left voicemail" => :left_voicemail,
        "Pledged" => :pledged,
        "Unknown action" => :unknown_action
      }
      attrs['event_type'] = event_type_mapping[attrs['event_type']]
      attrs
    end

    ActiveRecord::Base.transaction do
      migrate_model(pg, mongo, extra_transform)
    end
  end

  task clinic_user_patient: :environment do
    ActiveRecord::Base.transaction do
      # Start by moving clinics
      pg = Clinic
      mongo = MongoClinic
      extra_transform = Proc.new do |attrs, obj|
        attrs['mongo_id'] = obj['_id'].to_s
        attrs
      end
      migrate_model(pg, mongo, extra_transform)

      # Then users
      pg = User
      mongo = MongoUser
      # This doesn't seem to port over passwords.
      extra_transform = Proc.new do |attrs, obj|
        attrs['mongo_id'] = obj['_id'].to_s
        attrs['password'] = obj['encrypted_password'].to_s
        attrs['password_confirmation'] = obj['encrypted_password'].to_s
        attrs
      end
      migrate_model(pg, mongo, extra_transform)

      # Then patients/archivedpatients
      pt_model_pair = [[Patient, MongoPatient], [ArchivedPatient, MongoArchivedPatient]]
      pt_model_pair.each do |pair|
        pg, mongo = pair
        extra_transform = Proc.new do |attrs, obj|
          attrs['mongo_id'] = obj['_id'].to_s
          attrs['clinic_id'] = Clinic.find_by(mongo_id: obj['clinic_id'].to_s)&.id
          attrs['pledge_generated_by_id'] = User.find_by(mongo_id: obj['pledge_generated_by_id'].to_s)&.id
          attrs['pledge_sent_by_id'] = User.find_by(mongo_id: obj['pledge_sent_by_id'].to_s)&.id
          attrs['last_edited_by_id'] = User.find_by(mongo_id: obj['last_edited_by_id'].to_s)&.id if pg == Patient
          attrs
        end
        migrate_model(pg, mongo, extra_transform)
      end
      Fulfillment.destroy_all # These get made by callback and we want to copy them instead

      # At this point we loop thru the shared objs
      # Then calls
      pt_model_pair.each do |pair|
        pt, mongo_pt = pair
        pg = Call
        mongo = MongoCall
        extra_transform = Proc.new do |attrs, obj, doc|
          attrs['can_call'] = pt.find_by! mongo_id: doc['_id'].to_s
          attrs['status'] = MongoCall::ALLOWED_STATUSES[obj['status']]
          attrs
        end
        migrate_submodel(pt, mongo_pt, pg, mongo, 'calls', 'can_call', extra_transform)

        # Then ext pledges
        pg = ExternalPledge
        mongo = MongoExternalPledge
        extra_transform = Proc.new do |attrs, obj, doc|
          attrs['can_pledge'] = pt.find_by! mongo_id: doc['_id'].to_s
          attrs
        end
        migrate_submodel(pt, mongo_pt, pg, mongo, 'external_pledges', 'can_pledge', extra_transform)

        # Then psupports
        pg = PracticalSupport
        mongo = MongoPracticalSupport
        extra_transform = Proc.new do |attrs, obj, doc|
          attrs['can_support'] = pt.find_by! mongo_id: doc['_id'].to_s
          attrs
        end
        migrate_submodel(pt, mongo_pt, pg, mongo, 'practical_supports', 'can_support', extra_transform)

        # Then fulfillment
        pg = Fulfillment
        mongo = MongoFulfillment
        extra_transform = Proc.new do |attrs, obj, doc|
          attrs['can_fulfill'] = pt.find_by! mongo_id: doc['_id'].to_s
          attrs
        end
        migrate_submodel(pt, mongo_pt, pg, mongo, 'fulfillment', 'can_fulfill', extra_transform)
      end

      # Then, a few spares that are Patient only
      pt, mongo_pt = pt_model_pair[0]

      # Notes first
      pg = Note
      mongo = MongoNote
      extra_transform = Proc.new do |attrs, obj, doc|
        attrs['patient_id'] = Patient.find_by!(mongo_id: doc['_id'].to_s).id
        attrs
      end
      migrate_submodel(pt, mongo_pt, pg, mongo, 'notes', 'patient', extra_transform)

      # Then call list entries
      pg = CallListEntry
      mongo = MongoCallListEntry
      extra_transform = Proc.new do |attrs, obj, doc|
        attrs['patient_id'] = Patient.find_by!(mongo_id: obj['patient_id'].to_s).id
        attrs['user_id'] = User.find_by!(mongo_id: obj['user_id'].to_s).id
        attrs
      end
      migrate_model(pg, mongo, extra_transform)
    end
  end
end

# Convenience function to slice attributes
def migrate_model(pg_model, mongo_model, transform = nil)
  attributes = pg_model.attribute_names
  mongo_model.collection.find.batch_size(100).each do |obj|
    pg_attrs = obj.slice(*attributes)

    # If a model specific transform is required, do it here
    pg_attrs = transform.call(pg_attrs, obj) if transform.present?

    pg_obj = pg_model.create! pg_attrs

    if obj['created_by_id'].present?
      pg_obj.versions.first.update whodunnit: User.find_by(mongo_id: obj['created_by_id'].to_s)&.id
    end
  end

  if pg_model.count != mongo_model.count
    raise "PG and Mongo counts are in disagreement; aborting"
  end

  puts "#{pg_model.count} #{pg_model} migrated to pg"
end

def migrate_submodel(pt_model, mongo_pt_model, pg_model, mongo_model, relation, parent_relation, transform = nil)
  attributes = pg_model.attribute_names
  mongo_pt_model.collection.find.batch_size(100).each do |doc|
    mongo_objs = doc[relation] || []

    if mongo_objs.is_a? Array
      mongo_objs.each do |obj|
        pg_attrs = obj.slice(*attributes)

        # If a model specific transform is required, do it here
        pg_attrs = transform.call(pg_attrs, obj, doc) if transform.present?

        pg_obj = pg_model.create! pg_attrs
        if obj['created_by_id'].present?
          pg_obj.versions.first.update whodunnit: User.find_by(mongo_id: obj['created_by_id'].to_s)&.id
        end
      end
    else
      pg_attrs = mongo_objs.slice(*attributes)

      # If a model specific transform is required, do it here
      pg_attrs = transform.call(pg_attrs, mongo_objs, doc) if transform.present?

      pg_obj = pg_model.create! pg_attrs
      if mongo_objs['created_by_id'].present?
        pg_obj.versions.first.update whodunnit: User.find_by(mongo_id: mongo_objs['created_by_id'].to_s)&.id
      end
    end

    obj_count = pg_model.where(parent_relation.to_sym => pt_model.find_by!(mongo_id: doc['_id'].to_s)).count
    if mongo_objs.is_a? Array
      if obj_count != mongo_objs.count
        raise "PG and mongo counts for #{relation} are in disagreement; aborting"
      end
    else
      if obj_count > 1
        raise '??? better msg here'
      end
    end
  end
  puts "#{pg_model.count} #{relation} migrated to pg"
end
