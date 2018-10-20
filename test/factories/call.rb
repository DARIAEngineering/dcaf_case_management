FactoryBot.define do
  factory :call do
    association :patient
    status { 'Reached patient' }
    created_by { FactoryBot.create(:user) }
  end
end
