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
    before do
      @clinic = create :clinic
  
      @patient = create :patient
      @patient.clinic = @clinic
    end

    it 'should return nil if no email' do
      assert_nil clinic_pledge_email(@patient)
    end

    describe 'populated email case' do
      TEST_EMAIL_ADDRESS = "test.address@example.org"
      
      before do
        @clinic.email_for_pledges = TEST_EMAIL_ADDRESS
        @clinic.save!
      end
  
      it "should a mailto link for the clinic's email, given a patient" do
        email_link = clinic_pledge_email(@patient)
        # make sure we generate a link with the mailto href,
        # and also display the email in the link body.
        assert_match /href="mailto:#{TEST_EMAIL_ADDRESS}".*>#{TEST_EMAIL_ADDRESS}<\/a>/, email_link
      end
    end
  end
end
