FactoryBot.define do
  factory :archived_patient do
    line { 'DC' }
    initial_call_date { 400.days.ago }
  end
end
