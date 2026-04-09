namespace :encryption do
  desc 'Re-encrypt all encrypted records with the current primary key'
  task rotate_keys: :environment do
    models = [Patient, Note, Event, Clinic]
    Fund.all.each do |fund|
      ActsAsTenant.with_tenant(fund) do
        models.each do |model|
          next unless model.respond_to?(:encrypted_attributes) && model.encrypted_attributes.any?

          count = 0
          model.find_each do |record|
            record.encrypt
            count += 1
          end
          puts "#{Time.now} -- re-encrypted #{count} #{model.name} records (fund: #{fund.name})"
        end
      end
    end
  end
end
