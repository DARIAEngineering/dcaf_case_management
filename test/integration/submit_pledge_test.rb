require 'test_helper'

class SubmitPledgeTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    @patient = create :patient
    @pregnancy = create :pregnancy, patient: @patient
#     @patient.clinic_name = 'Nice Clinic'
#     @patient.appointment_date = DateTime.now + 14
#     @pregnancy.dcaf_soft_pledge = 500
    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name'
  end

  after do
    Capybara.use_default_driver
  end

  describe 'submitting a pledge' do
    it 'should let you mark a pledge submitted' do
      find('#submit-pledge-button').click
      assert has_text? 'Confirm the following information is correct'
      find('#submit-pledge-to-p2').click

      assert has_text? 'Review this preview of your pledge'
      find('#submit-pledge-to-p3').click

      assert has_text? 'Awesome, you generated a DCAF'
      check 'I sent the pledge'
      find('#submit-pledge-finish').click

      click_link 'Dashboard'
      visit edit_patient_path @patient
      assert has_text? Patient::STATUSES[:pledge_sent]
    end
  end
end
