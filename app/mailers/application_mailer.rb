class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{FUND_DOMAIN}"
  layout 'mailer'
end
