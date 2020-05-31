# app/mailers/user_mailer.rb
class UserMailer < Devise::Mailer
  default from: "no-reply@#{FUND_MAILER_DOMAIN}"

  def password_changed(id)
    @user = User.find(id)
    mail to: @user.email, subject: 'Your DARIA password has changed'
  end

  def account_created(id)
    @user = User.find(id)
    mail to: @user.email, subject: 'Your DARIA account has been created'
  end
end
