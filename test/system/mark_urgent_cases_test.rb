require 'application_system_test_case'

# Mark patients urgent and confirm that they show up on the dash after
class MarkUrgentCasesTest < ApplicationSystemTestCase
  before do
    @user = create :user
    @patient = create :patient
    log_in_as @user
    visit edit_patient_path(@patient)
    click_link 'Notes'
  end

  it 'should initially show an empty checkbox' do
    refute page.has_checked_field?('patient_urgent_flag')
  end

  it 'should move the case to urgent after checking the checkbox' do
    check 'patient_urgent_flag'
    wait_for_ajax

    visit dashboard_path
    within :css, '#urgent_cases' do
      assert has_text? @patient.name
    end
  end
end
