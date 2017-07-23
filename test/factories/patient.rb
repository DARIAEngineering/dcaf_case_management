FactoryGirl.define do
  factory :patient do
    name 'New Patient'
    sequence(:primary_phone, 100) { |n| "127-#{n}-1111" }
    line 'DC'
    language 'English'
    created_by { FactoryGirl.create(:user) }
    initial_call_date { 2.days.ago }
  end
end
