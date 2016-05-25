FactoryGirl.define do
  factory :pledge do
    pregnancy
		#association :pregnancy
    pledge_type 'Soft'
    amount 100
		created_by { FactoryGirl.create(:user) }
  end
end
