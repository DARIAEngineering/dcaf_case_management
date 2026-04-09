FactoryBot.define do
  factory :note_template do
    name { 'Standard follow-up' }
    full_text { 'Patient called back for follow-up. Status update recorded.' }
    fund
    user
  end
end
