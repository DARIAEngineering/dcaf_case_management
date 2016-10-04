FactoryGirl.define do
  factory :clinic do
    patient
    name 'Friendly Clinic'
    city 'Washington'
    state 'DC'
  end
end
