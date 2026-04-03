namespace :encryption do
  desc 'Re-encrypt all encrypted records with the current primary key'
  task rotate_keys: :environment do
    models = [Patient, Note, Event, Clinic]
    models.each do |model|
      count = 0
      model.find_each do |record|
        record.encrypt
        count += 1
      end
      puts "#{Time.now} -- re-encrypted #{count} #{model.name} records"
    end
  end
end
