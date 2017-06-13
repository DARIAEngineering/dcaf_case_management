require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'should send an email' do
    @user = create :user
    mail = UserMailer.password_changed(@user.id)
    assert_equal 'Your DARIA password has changed', mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ['no-reply@dcabortionfund.org'], mail.from
  end
end
