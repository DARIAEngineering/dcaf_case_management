FactoryBot.define do
  factory :external_pledge do
    patient
    sequence :source do |n|
      "Fund #{n}"
    end
    amount 100
    created_by { FactoryBot.create(:user) }
  end
end
