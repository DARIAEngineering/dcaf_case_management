FactoryGirl.define do
  factory :config do
    config_key 'insurance'
    config_value options: ['DC Medicaid', 'No insurance', "Don't know"]
    created_by { FactoryGirl.create(:user) }
  end
end
