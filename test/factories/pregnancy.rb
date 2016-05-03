FactoryGirl.define do
  factory :pregnancy do
    patient
    line 'DC'
    language 'English'
    created_by { FactoryGirl.create(:user) }
  end
end
