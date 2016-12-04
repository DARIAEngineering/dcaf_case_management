require 'test_helper'

class DashboardTest < ActionDispatch::IntegrationTest
  # problematic test
  before do
    @user = create :user
    @patient = create(:patient, initial_call_date: 3.days.ago, appointment_date: '2017-02-01', urgent_flag: true, created_by: @user)
    pregnancy = @patient.build_pregnancy(last_menstrual_period_weeks: 6, last_menstrual_period_days: 3, created_by: @user)
    pregnancy.save

    @patient.calls.create!(status: 'Left voicemail', created_at: 3.days.ago, updated_at: 3.days.ago, created_by: @user)

    @user.add_patient @patient

    log_in_as @user
  end

  describe 'visiting the dashboard' do
    it 'Table with user\'s call list should display appointment date field' do
      assert page.find_by_id('call_list').has_content? 'Appointment date'
      assert page.find_by_id('call_list').has_content? @patient.appointment_date
    end

    it 'Table with user\'s completed calls should display appointment date field' do
      assert page.find_by_id('completed_calls').has_content? 'Appointment date'
      refute page.find_by_id('completed_calls').has_content? @patient.appointment_date
    end

    it 'Table with urgent cases should display appointment date field' do
      assert page.find_by_id('urgent_patients').has_content? 'Appointment date'
      assert page.find_by_id('urgent_patients').has_content? @patient.appointment_date
    end
  end
end
