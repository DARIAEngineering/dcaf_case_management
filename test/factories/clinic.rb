FactoryGirl.define do
  factory :clinic do
    sequence :name do |n| 
      "Friendly Clinic #{n}"
    end
    street_address '123 Fake Street'
    city 'Washington'
    state 'DC'
    zip '20011'
  end
end
