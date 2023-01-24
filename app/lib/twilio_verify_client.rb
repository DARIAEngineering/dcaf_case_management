# frozen_string_literal: true

require 'rubygems'
require 'twilio-ruby'

# Help: https://www.twilio.com/docs/verify/quickstarts/totp
class TwilioVerifyClient
  # For development these values can be found in the Twilio Console at https://console.twilio.com.
  TWILIO_ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID']
  TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']
  TWILIO_SMS_SERVICE = ENV['TWILIO_SMS_SERVICE']

  def initialize
    @client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
  end

  def send_sms_verification_code(phone_number)
    verification = @client.verify
                          .v2
                          .services(TWILIO_SMS_SERVICE)
                          .verifications
                          .create(to: "+1#{phone_number}", channel: 'sms')

    verification.status
  end

  def check_sms_verification_code(phone_number, code)
    verification_check = @client.verify
                                .v2
                                .services(TWILIO_SMS_SERVICE)
                                .verification_checks
                                .create(to: "+1#{phone_number}", code: code)

    verification_check.status
  end
end
