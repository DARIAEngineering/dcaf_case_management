FactoryGirl.define do
  factory :user do
    name 'Billy Everyteen'
    sequence :email do |n|
       "billy#{n}@everyteen.com"
     end
    password 'password'
  end
end
