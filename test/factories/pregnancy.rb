FactoryGirl.define do
  factory :pregnancy do
    patient
    line 'DC'
    language 'English'
    initial_call_date { 2.days.ago }
    created_by { FactoryGirl.create(:user) }
  end
end
