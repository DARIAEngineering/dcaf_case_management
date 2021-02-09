FactoryBot.define do
  factory :call do
    association :patient
    status { :reached_patient }
  end
end
