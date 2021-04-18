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
      end
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

def migrate_fulfillment(pt_model, mongo_pt_model, pg_model, mongo_model, relation, parent_relation, transform)
  attributes = pg_model.attribute_names
  mongo_pt_model.collection.find.batch_size(100).each do |doc|
    mongo_obj = doc[relation]

    pg_attrs = transform.call(mongo_obj.slice(*attributes), mongo_obj, doc)
    pg_obj = pg_model.create! pg_attrs
    if mongo_obj['created_by_id'].present?
      pg_obj.versions.first.update whodunnit: User.find_by(mongo_id: mongo_obj['created_by_id'].to_s)&.id
    end

    # Check
    if pg_model.count != mongo_model.count
      raise 'PG and mongo counts are in disagreement, aborting'
    end
    if pg_model.count != Patient.count
      'Every patient not associated with only one fulfillment'
    end
  end
end
