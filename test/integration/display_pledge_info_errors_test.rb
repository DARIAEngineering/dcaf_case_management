require 'test_helper'

class DisplayPledgeInfoErrorsTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    @patient = create :patient
    @pregnancy = create :pregnancy, patient: @patient
    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name' # wait until page loads
  end

  after do
    Capybara.use_default_driver
  end

  describe 'rendering errors in patient modal' do
    it 'should render errors when popping up the pledge sent modal' do
      find('#submit-pledge-button').click
      assert has_text? 'Confirm the following information is correct'
      assert has_text? 'Data required:'
      # TODO: Refute that button will let you continue
    end

    it 'should not show errors when information is present' do
      @patient = create :patient, clinic_name: 'Nice Clinic', appointment_date: DateTime.now + 14
      @pregnancy = create :pregnancy, patient: @patient, dcaf_soft_pledge: 500
      visit edit_patient_path @patient

      find('#submit-pledge-button').click
      assert has_text? 'Confirm the following information is correct'
      find('#submit-pledge-to-p2').click
      refute has_text? 'Confirm the following information is correct'
    end
  end
end
