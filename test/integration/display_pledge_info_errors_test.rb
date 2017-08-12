require 'application_system_test_case'

class DisplayPledgeInfoErrorsTest < ApplicationSystemTestCase
  before do
    @user = create :user
    @patient = create :patient
    @clinic = create :clinic
    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name' # wait until page loads
  end

  describe 'rendering errors in patient modal' do
    it 'should render errors when popping up the pledge sent modal' do
      find('#submit-pledge-button').click
      assert has_text? 'Confirm the following information is correct'
      assert has_text? 'Data required:'
      assert has_css? 'button:disabled', text: 'Next'
    end

    it 'should not show errors when information is present' do
      @patient = create :patient, clinic: @clinic,
                                  appointment_date: 14.days.from_now,
                                  fund_pledge: 500
      visit edit_patient_path @patient

      find('#submit-pledge-button').click
      assert has_text? 'Confirm the following information is correct'
      assert has_text? @patient.name
      assert has_text? @patient.identifier
      # TODO: check for pledge, appt date, and clinic

      find('#pledge-next').click
      wait_for_no_element 'Confirm the following information is correct'

      refute has_text? 'Review this preview of you pledge'
    end
  end
end
