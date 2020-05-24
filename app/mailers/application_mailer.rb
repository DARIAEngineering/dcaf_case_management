class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{FUND_MAILER_DOMAIN}"
  layout 'mailer'
end
