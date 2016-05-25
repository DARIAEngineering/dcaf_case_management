FactoryGirl.define do
  factory :pledge do
    pregnancy
    pledge_type 'Soft'
    amount 100
    after :build do |pledge, eval|
      pledge.created_by_id = FactoryGirl.create(:user)
    end
  end
end
