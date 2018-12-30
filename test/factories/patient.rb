FactoryBot.define do
  factory :patient do
    name { Faker::Name.name }
    sequence(:primary_phone, 100) { |n| "127-#{n}-1111" }
    line { 'DC' }
    created_by { FactoryBot.create(:user) }
    initial_call_date { 2.days.ago }
  end
end
