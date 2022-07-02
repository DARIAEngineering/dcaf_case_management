require 'test_helper'

class PledgesHelperTest < ActionView::TestCase
  describe 'convenience methods' do
    describe 'submit_pledge_button' do
      it 'should return a span tag' do
        assert_match /span/, submit_pledge_button
        assert_match /Submit pledge/, submit_pledge_button
      end
    end
  end

  describe 'contact info methods' do
    describe 'clinic pledge email' do
      TEST_EMAIL_ADDRESS = "test.address@example.org"
      before do
        @clinic = create :clinic
        @clinic.email_for_pledges = TEST_EMAIL_ADDRESS
  
        @patient = create :patient
        @patient.clinic = @clinic
      end
  
      it 'should return the email for a clinic, given a patient' do
        email_link = clinic_pledge_email(@patient)
        # make sure we generate a link with the mailto href,
        # and also display the email in the link body.
        assert_match /href="mailto:#{TEST_EMAIL_ADDRESS}".*>#{TEST_EMAIL_ADDRESS}<\/a>/, email_link
      end
    end
  end
end
