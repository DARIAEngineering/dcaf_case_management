FactoryGirl.define do
  factory :external_pledge do
    patient
    sequence :source do |n|
      "Fund #{n}"
    end
    amount 100
    created_by { FactoryGirl.create(:user) }
  end
end
