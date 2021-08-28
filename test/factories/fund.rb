FactoryBot.define do
  factory :fund do
    sequence :name do |n|
      "Fund #{n}"
    end
    sequence :full_name do |n|
      "Fund #{n} of Cat Town"
    end
  end
end
