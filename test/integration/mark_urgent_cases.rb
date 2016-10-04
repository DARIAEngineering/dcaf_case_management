require 'test_helper'

class MarkUrgentCasesTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    log_in_as @user
    @patient = create :patient
    @pregnancy = create :pregnancy, patient: @patient
    visit edit_patient_path(@patient)
    click_link 'Notes'
  end

  after do
    Capybara.use_default_driver
  end
  
  it 'should initially show an empty checkbox' do
    refute page.has_checked_field?('patient_urgent_flag')
  end

  it 'should move the case to urgent after checking the checkbox' do
    check 'patient_urgent_flag' 
    visit dashboard_path
    within :css, '#urgent_patients' do
      assert has_text? @patient.name
    end
  end
end