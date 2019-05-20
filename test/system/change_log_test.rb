require 'application_system_test_case'

# Confirm that changes to patient record show up in the changelog
class ChangeLogTest < ApplicationSystemTestCase
  before do
    @user = create :user, email: 'first_user@email.com'
    @patient = create :patient, name: 'tester',
                                primary_phone: '1231231234',
                                created_by: @user,
                                city: 'Washington'

    log_in_as @user
    visit edit_patient_path(@patient)
  end

  describe 'viewing the changelog' do
    it 'should log patient accessibly' do
      fill_in 'City', with: 'Canada'
      click_away_from_field

      wait_for_element 'Change Log'
      click_link 'Change Log'
      wait_for_element 'Patient history'

      within :css, '#change_log' do
        assert has_text? Time.zone.now.display_date
        assert has_text? 'City: Washington -> Canada'
        assert has_text? @user.name
      end
    end
  end
end
