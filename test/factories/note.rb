FactoryGirl.define do
  factory :note do
    association :pregnancy
    full_text 'behold, a note'
    created_by { FactoryGirl.create(:user) }
  end
end
