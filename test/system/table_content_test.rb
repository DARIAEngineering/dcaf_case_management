require 'application_system_test_case'

# Testing around call list table content
class TableContentTest < ApplicationSystemTestCase
  # problematic test
  before do
    @user = create :user
    @patient = create :patient, initial_call_date: 3.days.ago,
                                appointment_date: 3.days.from_now.utc,
                                urgent_flag: true,
                                created_by: @user,
                                last_menstrual_period_weeks: 6,
                                last_menstrual_period_days: 3

    @patient.calls.create status: 'Left voicemail',
                          created_at: 3.days.ago,
                          updated_at: 3.days.ago,
                          created_by: @user

    @user.add_patient @patient
    log_in_as @user
    wait_for_element 'Build your call list'
  end

  describe 'visiting the dashboard' do
    it 'should display attributes in call list table' do
      within :css, '#call_list_content' do
        assert has_content? @patient.primary_phone_display
        assert has_content? @patient.name
        assert has_content? 3.days.from_now.utc.strftime('%m/%d/%Y')
        assert has_content? @patient.last_menstrual_period_display_short
        # TODO: has remove, phone clicky
      end
    end
  end
end
