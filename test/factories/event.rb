FactoryBot.define do
  factory :event do
    event_type { 'Reached patient' }
    cm_name { 'Yolorita' }
    patient_name { 'Susan Everyteen' }
    patient_id { 'sdfghjk' }
  end
end
