FactoryGirl.define do
  factory :call do
    association :pregnancy
    status 'Reached patient'
    created_by { FactoryGirl.create(:user) }
  end
end
