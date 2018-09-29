FactoryBot.define do
  factory :note do
    patient
    full_text { 'behold, a note' }
    created_by { FactoryBot.create(:user) }
  end
end
