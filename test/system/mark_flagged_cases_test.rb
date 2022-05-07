require 'application_system_test_case'

# Mark patients flagged and confirm that they show up on the dash after
class MarkFlaggedCasesTest < ApplicationSystemTestCase
  before do
    @user = create :user
    @patient = create :patient
    log_in_as @user
    visit edit_patient_path(@patient)
    click_link 'Notes'
  end

  it 'should initially show an empty checkbox' do
    refute page.has_checked_field?('patient_flagged')
  end

  it 'should mark the case flagged after checking the checkbox' do
    check 'patient_flagged'
    wait_for_ajax

    visit dashboard_path
    within :css, '#flagged_cases' do
      assert has_text? @patient.name
    end
  end
end
