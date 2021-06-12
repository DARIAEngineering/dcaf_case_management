FactoryBot.define do
  factory :note do
    patient
    full_text { 'behold, a note' }
  end
end
