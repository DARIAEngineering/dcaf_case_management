FactoryBot.define do
  factory :fund do
    sequence :name do |n|
      "Fund #{n}"
    end
    sequence :subdomain do |n|
      "fund#{n}"
    end
    domain { 'example.com' }
    sequence :full_name do |n|
      "Fund #{n} of Cat Town"
    end
    sequence :site_domain do |n|
      "www.fund#{n}.pizza"
    end
    phone { '(939)-555-0113' }
  end
end
