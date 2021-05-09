FactoryBot.define do
  factory :practical_support do
    patient
    sequence :source do |n|
      "Fund #{n}"
    end
    sequence :support_type do |n|
      "Support #{n}"
    end
    confirmed { false }
  end
end
