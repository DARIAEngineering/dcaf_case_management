class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{FUND_DOMAIN}.org"
  layout 'mailer'
end
