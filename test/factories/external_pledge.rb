FactoryBot.define do
  factory :external_pledge do
    patient
    sequence :source do |n|
      "Fund #{n}"
    end
    amount { 100 }
  end
end
