namespace :migrate_to_pg do
  desc 'Migrate Config from Mongo to Postgres'
  task config: :environment do
    pg = Config
    mongo = MongoConfig
    migrate_model(pg, mongo)
  end
end

# Convenience function to slice attributes
def migrate_model(pg_model, mongo_model)
  attributes = pg_model.attribute_names
  ActiveRecord::Base.transaction do
    mongo_model.collection.find.batch_size(100).each do |obj|
      pg_attrs = obj.slice(*attributes)
      pg_model.create! pg_attrs
    end

    if pg_model.count != mongo_model.count
      raise "PG and Mongo counts are in disagreement; aborting"
    end
  end

  puts "#{pg_model.count} migrated to pg"
end
