namespace :patient do
  desc "update patients to be encrypted with ActiveRecord encryption"
  task encrypt_sensitive_columns: :environment do
    Patient.all.find_each do |patient|
      patient.encrypt
    end
  end
end
