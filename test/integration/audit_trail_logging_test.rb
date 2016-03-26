require 'test_helper'

class AuditTrailLoggingTest < ActionDispatch::IntegrationTest
  def setup
    @user = create :user, email: 'first_user@email.com'
    @user2 = create :user, email: 'second_user@email.com'
    log_in_as @user
    @patient = create :patient, name: 'tester', primary_phone: '1231231234'
    @pregnancy = create :pregnancy, appointment_date: nil, patient: @patient
    visit edit_pregnancy_path(@pregnancy)
  end

  describe 'A patient was created at some point' do
    it 'posts changes and verifies audit trail in db' do
      assert_equal @patient.history_tracks.count, 1
      assert_equal @patient.created_by, @user
      assert_equal page.find(:id, 'pregnancy_patient_name').value, 'tester'
      fill_in 'Name', with: 'changed'
      click_button 'TEMP: SAVE INFORMATION'
      @patient.reload
      assert_equal @patient.name, 'changed'
      assert_equal @patient.history_tracks.count, 2
      assert_equal @patient.updated_by, @user
      sign_out
      log_in_as @user2
      visit edit_pregnancy_path(@pregnancy)
      assert_equal page.find(:id, 'pregnancy_patient_name').value, 'changed'
      fill_in 'Name', with: 'more change'
      click_button 'TEMP: SAVE INFORMATION'
      @patient.reload
      assert_equal @patient.name, 'more change'
      assert_equal @patient.history_tracks.count, 3
      assert_equal @patient.updated_by, @user2
    end
  end
end
