class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{ENV['FUND_MAILER_DOMAIN'] || 'dcabortionfund.org'}"
  layout 'mailer'
end
