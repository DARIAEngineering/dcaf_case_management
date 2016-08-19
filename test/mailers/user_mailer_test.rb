require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'should send an email' do
    @user = create :user
    mail = UserMailer.password_changed(@user.id)
    assert_equal "Password changed", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
