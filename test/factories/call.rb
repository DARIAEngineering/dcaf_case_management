FactoryBot.define do
  factory :call do
    association :patient
    status { 'Reached patient' }
  end
end
