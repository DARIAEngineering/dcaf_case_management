FactoryGirl.define do
  factory :call do
    association :patient
    status 'Reached patient'
    created_by { FactoryGirl.create(:user) }
  end
end
