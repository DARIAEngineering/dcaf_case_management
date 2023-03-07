FactoryBot.define do
  sequence :name do |n|
    "my phone #{n}"
  end

  factory :auth_factor do
    association :user
    channel { 'sms' }

    trait :registration_complete do
      name { generate :name }
      phone { '555-555-5555' }
      registration_complete { true }
      enabled { true }
    end

    trait :not_enabled do
      name { generate :name }
      registration_complete { false }
      enabled { false }
    end
  end
end
