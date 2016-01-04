FactoryGirl.define do
  factory :user do
    name "Billy Everyteen"
    email "billy@everyteen.com"
    confirmed_at { 2.months.ago }
  end
end