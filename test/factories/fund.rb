FactoryBot.define do
  factory :fund do
    sequence :name do |n|
      "Fund #{n}"
    end
    sequence :subdomain do |n|
      "fund#{n}"
    end
    domain { 'example.com' }
  end
end
