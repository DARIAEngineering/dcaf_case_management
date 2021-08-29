FactoryBot.define do
  factory :archived_patient do
    initial_call_date { 400.days.ago }
    line
  end
end
