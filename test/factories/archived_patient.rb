FactoryBot.define do
  factory :archived_patient do
    line { 'DC' }
    created_by { FactoryBot.create(:user) }
    initial_call_date { 400.days.ago }
  end
end
