FactoryGirl.define do
  factory :patient do
    name 'New Patient'
    primary_phone '123-123-1234'
    spanish false
    created_by { FactoryGirl.create(:user) }
    initial_call_date { 2.days.ago }
  end
end
