FactoryBot.define do
  factory :call_list_entry do
    user
    patient
    line { 'DC' }
    sequence :order_key do |n|
      n
    end
  end
end
