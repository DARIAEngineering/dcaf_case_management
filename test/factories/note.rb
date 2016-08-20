FactoryGirl.define do
  factory :note do
    patient
    full_text 'behold, a note'
    created_by { FactoryGirl.create(:user) }
  end
end
