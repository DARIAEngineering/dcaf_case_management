desc 'One-time migration to postgres'
task migrate_to_pg: :environment do
  BATCH_SIZE = 100

  attributes = User.attribute_names
  ActiveRecord::Base.transaction do
    MongoUser.collection.find.batch_size(100).order_by(:id).each do |user|
      user_attrs = user.slice(*attributes).merge(password: user[:encrypted_password].to_s, password_confirmation: user[:encrypted_password].to_s)
      User.create user_attrs
    end
  end

  puts User.count
end
