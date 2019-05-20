FactoryBot.define do
  factory :user do
    name { 'Billy Everyteen' }
    sequence :email do |n|
      "billy#{n}@everyteen.com"
    end
    password { 'FCZCidQP4C8GTz' }
    password_confirmation { 'FCZCidQP4C8GTz' }
  end
end
