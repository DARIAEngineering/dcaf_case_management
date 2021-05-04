namespace :migrate_to_pg do
  desc 'Migrate Config from Mongo to Postgres'
  task config: :environment do
    ActiveRecord::Base.transaction do
      pg = Config
      mongo = MongoConfig
      migrate_model(pg, mongo)
    end
  end

  task event: :environment do
    ActiveRecord::Base.transaction do
      pg = Event
      mongo = MongoEvent

      extra_transform = Proc.new do |attrs|
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
      migrate_model pg, mongo, extra_transform

      # Next, users
      pg = User
      mongo = MongoUser
      # This doesn't seem to port over passwords, maybe because encryptor changed?
      extra_transform = Proc.new do |attrs, obj|
        attrs['mongo_id'] = obj['_id'].to_s
        attrs['password'] = obj['encrypted_password'].to_s
        attrs['password_confirmation'] = obj['encrypted_password'].to_s
        attrs
      end
      migrate_model pg, mongo, extra_transform

      # Then patients
      pt_model_pair = [[Patient, MongoPatient]]
      pt_model_pair.each do |pair|
        pg, mongo = pair
        extra_transform = Proc.new do |attrs, obj|
          attrs['mongo_id'] = obj['_id'].to_s
          attrs['clinic_id'] = Clinic.find_by(mongo_id: obj['clinic_id'].to_s)&.id
          attrs['pledge_generated_by_id'] = User.find_by(mongo_id: obj['pledge_generated_by_id'].to_s)&.id
          attrs['pledge_sent_by_id'] = User.find_by(mongo_id: obj['pledge_sent_by_id'].to_s)&.id
          attrs['last_edited_by_id'] = User.find_by(mongo_id: obj['last_edited_by_id'].to_s)&.id
          attrs
        end
        migrate_model(pg, mongo, extra_transform)
      end
      Fulfillment.destroy_all # these get made by callback and we want to copy them instead

      # Then, we loop through shared objects
      pt_model_pair.each do |pair|
        pt, mongo_pt = pair

        # First, fulfillment
        pg = Fulfillment
        mongo = MongoFulfillment
        extra_transform = Proc.new do |attrs, obj, doc|
          attrs['can_fulfill'] = pt.find_by! mongo_id: doc['_id'].to_s
          attrs
        end
        migrate_fulfillment(pt, mongo_pt, pg, mongo, 'fulfillment', 'can_fulfill', extra_transform)

        # Next, calls
        pg = Call
        mongo = MongoCall
        extra_transform = Proc.new do |attrs, obj, doc|
          attrs['can_call'] = pt.find_by! mongo_id: doc['_id'].to_s
          attrs['status'] = MongoCall::ALLOWED_STATUSES[obj['status']]
          attrs
        end
        migrate_submodel(pt, mongo_pt, pg, mongo, 'calls', 'can_call', extra_transform)
      end

      # Then, a couple spares that are Patient only
      pt = Patient
      mongo_pt = MongoPatient

      # Call List Entries
      pg = CallListEntry
      mongo = MongoCallListEntry
      extra_transform = Proc.new do |attrs, obj|
        attrs['patient_id'] = Patient.find_by!(mongo_id: obj['patient_id'].to_s).id
        attrs['user_id'] = User.find_by!(mongo_id: obj['user_id'].to_s).id
        attrs
      end
      migrate_model(pg, mongo, extra_transform)

      # Notes
      pg = Note
      mongo = MongoNote
      extra_transform = Proc.new do |attrs, obj, doc|
        attrs['patient'] = pt.find_by! mongo_id: doc['_id'].to_s
        attrs
      end
      migrate_submodel(pt, mongo_pt, pg, mongo, 'notes', 'patient', extra_transform)
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
    raise "PG and Mongo counts are in disagreement (#{pg_model.count} and #{mongo_model.count}); aborting"
  end

  puts "#{pg_model.count} #{pg_model} migrated to pg"
end

def migrate_fulfillment(pt_model, mongo_pt_model, pg_model, mongo_model, relation, parent_relation, transform)
  attributes = pg_model.attribute_names
  mongo_pt_model.collection.find.batch_size(100).each do |doc|
    mongo_obj = doc[relation]

    pg_attrs = transform.call(mongo_obj.slice(*attributes), mongo_obj, doc)
    pg_obj = pg_model.create! pg_attrs
    if mongo_obj['created_by_id'].present?
      pg_obj.versions.first.update whodunnit: User.find_by(mongo_id: mongo_obj['created_by_id'].to_s)&.id
    end
  end

  # Check
  if pg_model.count != Patient.count
    raise 'Every patient not associated with only one fulfillment'
  end

  puts "#{pg_model.count} Fulfillment migrated to pg"
end

# handles patient has_many submodels
def migrate_submodel(pt_model, mongo_pt_model, pg_model, mongo_model, relation, parent_relation, transform)
  attributes = pg_model.attribute_names
  mongo_pt_model.collection.find.batch_size(100).each do |doc|
    mongo_objs = doc[relation] || []
    mongo_objs.each do |obj|
      pg_attrs = obj.slice(*attributes)
      pg_attrs = transform.call(pg_attrs, obj, doc)
      pg_obj = pg_model.create! pg_attrs

      if obj['created_by_id'].present?
        pg_obj.versions.first.update whodunnit: User.find_by(mongo_id: obj['created_by_id'].to_s)&.id
      end
    end

    # Check
    obj_count = pg_model.where(parent_relation.to_sym => pt_model.find_by!(mongo_id: doc['_id'].to_s)).count
    if obj_count != mongo_objs.count
      raise "PG and mongo counts for #{relation} are in disagreement (#{obj_count} and #{mongo_objs.count}); aborting"
    end
  end

  puts "#{pg_model.count} #{relation} migrated to pg"
end
