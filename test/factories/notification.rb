FactoryBot.define do
  factory :notification do
    user
    title { 'Test Notification' }
    body { 'Test notification body text' }
    notification_type { 'info' }
    link { nil }
  end
end
