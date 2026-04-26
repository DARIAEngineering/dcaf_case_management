namespace :patient do
  desc "update patients to be encrypted with ActiveRecord encryption"
  task encrypt_sensitive_columns: :environment do
    Fund.all.each do |fund|
      ActsAsTenant.with_tenant(fund) do
        Patient.all.find_each do |patient|
          patient.encrypt
        end
      end
    end
  end
end
