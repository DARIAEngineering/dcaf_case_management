FactoryBot.define do
  factory :fulfillment do
    patient
    created_by { FactoryBot.create(:user) }
  end
end
