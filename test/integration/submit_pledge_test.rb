require 'test_helper'

class SubmitPledgeTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    @clinic = create :clinic
    @patient = create :patient, clinic: @clinic,
                                appointment_date: Time.zone.now + 14,
                                fund_pledge: 500
    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name'
  end

  after { Capybara.use_default_driver }

  describe 'submitting a pledge' do
    it 'should let you mark a pledge submitted' do
      find('#submit-pledge-button').click
      wait_for_element 'Patient name'
      assert has_text? 'Confirm the following information is correct'
      find('#pledge-next').click
      sleep 2 # out of ideas

      wait_for_no_element 'Confirm the following information is correct'
      assert has_text? 'Generate your pledge form'
      find('#pledge-next').click
      wait_for_no_element 'Review this preview of your pledge'

      assert has_text? 'Awesome, you generated a DCAF'
      check 'I sent the pledge'
      wait_for_ajax
      find('#pledge-next').click
      wait_for_no_element 'Awesome, you generated a DCAF'

      go_to_dashboard
      visit edit_patient_path @patient
      wait_for_element 'Patient information'

      assert has_text? Patient::STATUSES[:pledge_sent]
    end
  end
end
