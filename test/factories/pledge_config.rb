FactoryBot.define do
  factory :pledge_config do
    sequence :contact_email do |n|
      "contact#{n}@everyteen.com"
    end
    sequence :billing_email do |n|
      "billing#{n}@everyteen.com"
    end
    address1 { '123 Fake Street' }
    address2 { 'Fakeytown, WA 98765' }
    phone { '281-330-8004' }
    fund
  end
end
