FactoryGirl.define do
  factory :fulfillment do
    patient
    created_by { FactoryGirl.create(:user) }
  end
end
