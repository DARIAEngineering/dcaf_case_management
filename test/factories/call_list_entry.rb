FactoryBot.define do
  factory :call_list_entry do
    user
    patient
    line
    sequence :order_key
  end
end
