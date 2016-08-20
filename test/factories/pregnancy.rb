FactoryGirl.define do
  factory :pregnancy do
    patient
    created_by { FactoryGirl.create(:user) }
  end
end
