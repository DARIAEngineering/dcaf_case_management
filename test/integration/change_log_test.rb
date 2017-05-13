require 'test_helper'

class ChangeLogTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user, email: 'first_user@email.com'
    @user2 = create :user, email: 'second_user@email.com'
    log_in_as @user
    @patient = create :patient, name: 'tester',
                                primary_phone: '1231231234',
                                created_by: @user2

    visit edit_patient_path(@patient)
    fill_in 'City', with: 'Washington'
  end

  after do
    Capybara.use_default_driver
  end

  describe 'viewing the changelog' do
    it 'should log patient accessibly' do
      fill_in 'City', with: 'Washington'
      visit edit_patient_path(@patient)
      wait_for_element 'Change Log'
      click_link 'Change Log'
      wait_for_element 'Patient history'

      within :css, '#change_log' do
        assert has_text? Time.zone.now.display_date
        assert has_text? 'City'
        assert has_text? 'Washington'
        assert has_text? @user.name
      end
    end
  end
end
