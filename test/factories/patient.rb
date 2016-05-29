FactoryGirl.define do
  factory :patient do
    name 'New Patient'
    primary_phone '123-123-1234'
    created_by { FactoryGirl.create(:user) }
  end
end
