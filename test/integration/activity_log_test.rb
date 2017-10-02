require 'test_helper'

# Confirm that calls and pledges are showing up in activity log
class ActivityLogTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    @clinic = create :clinic
    @patient = create :patient,
                      fund_pledge: 100,
                      clinic: @clinic,
                      appointment_date: 3.days.from_now

    log_in_as @user
    choose_line 'dc'
    visit edit_patient_path @patient
  end

  after { Capybara.use_default_driver }

  describe 'logging phone calls' do
    it 'should log a phone call into the activity log' do
      wait_for_element 'Call Log'
      click_link 'Call Log'
      click_link 'Record new call'
      click_link 'I left a voicemail for the patient'

      visit authenticated_root_path
      within :css, '#activity_log_content' do
        assert has_content? "#{@user.name} left a voicemail for " \
                            "#{@patient.name}"
      end
    end
  end

  describe 'logging a pledge' do
    it 'should log a pledge into the activity log' do
      find('#submit-pledge-button').click
      wait_for_element 'Patient name'
      assert has_text? 'Confirm the following information is correct'
      click_button 'Next'
      wait_for_element 'Generate your pledge form'
      click_button 'Next'
      check 'I sent the pledge'
      wait_for_ajax

      visit authenticated_root_path
      within :css, '#activity_log_content' do
        assert has_content? "#{@user.name} sent a $#{@patient.fund_pledge} " \
                            "pledge for #{@patient.name}"
      end
    end
  end
end
