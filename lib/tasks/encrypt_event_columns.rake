namespace :event do
  desc "update events to be encrypted with ActiveRecord encryption"
  task encrypt_sensitive_columns: :environment do
    Event.all.find_each do |event|
      event.encrypt
    end
  end
end
