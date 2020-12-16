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

  task clinic: :environment do
    pg = Clinic
    mongo = MongoClinic

    extra_transform = Proc.new do |attrs|
      attrs['mongo_id'] = attrs['id'] # Save Mongo UUID
      attrs
    end

    migrate_model(pg, mongo, extra_transform)
  end
end

# Convenience function to slice attributes
def migrate_model(pg_model, mongo_model, transform = nil)
  attributes = pg_model.attribute_names
  ActiveRecord::Base.transaction do
    mongo_model.collection.find.batch_size(100).each do |obj|
      pg_attrs = obj.slice(*attributes)

      # If a model specific transform is required, do it here
      pg_attrs = transform.call(pg_attrs) if transform.present?

      pg_model.create! pg_attrs
    end

    if pg_model.count != mongo_model.count
      raise "PG and Mongo counts are in disagreement; aborting"
    end
  end

  puts "#{pg_model.count} migrated to pg"
end
