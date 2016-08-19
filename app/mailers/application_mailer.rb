class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@dcaf.org"
  layout 'mailer'
end
