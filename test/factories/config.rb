FactoryBot.define do
  factory :config do
    config_key :insurance
    config_value options: ['DC Medicaid', 'No insurance', "Don't know"]
    created_by { FactoryBot.create(:user) }
  end
end
