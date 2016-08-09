require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "password_changed" do
    mail = UserMailer.password_changed
    assert_equal "Password changed", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
