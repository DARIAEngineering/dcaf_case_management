FactoryBot.define do
  factory :fund do
    sequence :name do |n|
      "Fund #{n}"
    end
  end
end
