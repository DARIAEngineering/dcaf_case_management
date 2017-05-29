class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{ENV['FUND_DOMAIN']}.org"
  layout 'mailer'
end
