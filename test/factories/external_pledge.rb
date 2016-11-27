FactoryGirl.define do
  factory :external_pledge do
    patient
    source 'Other fund'
    amount 100
    created_by { FactoryGirl.create(:user) }
  end
end
