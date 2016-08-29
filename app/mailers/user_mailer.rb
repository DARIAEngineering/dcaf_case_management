# app/mailers/user_mailer.rb
class UserMailer < Devise::Mailer
  default from: 'no-reply@dcaf.org'

  def password_changed(id)
    @user = User.find(id)
    mail to: @user.email, subject: 'Your password has changed'
  end
end
