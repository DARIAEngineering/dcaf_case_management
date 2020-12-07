FactoryBot.define do
  factory :config do
    config_key { :insurance }
    config_value { { options: ['DC Medicaid', 'No insurance', "Don't know"] } }
  end
end
