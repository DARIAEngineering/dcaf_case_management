namespace :clinic do
  desc "update clinics to be encrypted with ActiveRecord encryption"
  task encrypt_sensitive_columns: :environment do
    Clinic.all.find_each do |clinic|
      clinic.encrypt
    end
  end
end