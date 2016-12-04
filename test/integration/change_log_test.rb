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
    @pregnancy = create :pregnancy, patient: @patient,
                                    created_by: @user2

    visit edit_patient_path(@patient)
    fill_in 'City', with: 'Washington'
  end

  after do
    Capybara.use_default_driver
  end

  describe 'viewing the changelog' do
    # not yet enabled
    # it 'should log pregnancy accessibly' do
    #   select '5 weeks', from: 'patient_pregnancy_last_menstrual_period_weeks'
    #   fill_in 'Appointment date', with: 2.days.from_now.strftime('%Y-%m-%d')
    #   visit edit_patient_path(@patient)
    #   wait_for_element 'Change Log'
    #   click 'Change Log'
    #   wait_for_element 'Patient history'

    #   within :css, '#change_log' do
    #     assert has_text? Time.zone.now.display_date
    #     assert has_text? 'Appointment date'
    #     assert has_text? '5 weeks'
    #     assert has_text? @user.name
    #   end
    # end

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
