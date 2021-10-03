FactoryBot.define do
  factory :line do
    sequence :name do |n|
      "Line#{n}"
    end
    fund
  end
end
