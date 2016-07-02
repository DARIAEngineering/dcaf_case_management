require 'test_helper'

class AuditTrailLoggingTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user, email: 'first_user@email.com'
    @user2 = create :user, email: 'second_user@email.com'
    log_in_as @user
    @patient = create :patient, name: 'tester',
                                primary_phone: '1231231234',
                                created_by: @user
    @pregnancy = create :pregnancy, appointment_date: nil,
                                    patient: @patient,
                                    created_by: @user
    visit edit_pregnancy_path(@pregnancy)
  end

  after do
    Capybara.use_default_driver
  end

  describe 'A patient was created at some point', js: true do
    it 'posts changes and verifies audit trail in db' do
      assert_equal @patient.history_tracks.count, 1
      assert_equal @patient.created_by, @user
      assert_equal page.find(:id, 'pregnancy_patient_name').value, 'tester'
      fill_in 'First and last name', with: 'changed'
      # click to a different field to trigger js
      fill_in 'Phone number', with: @patient.primary_phone
      @patient.reload
      assert_equal @patient.name, 'changed'
      assert_equal @patient.history_tracks.count, 2
      assert_equal @patient.updated_by, @user

      sign_out
      log_in_as @user2
      visit edit_pregnancy_path(@pregnancy)
      assert_equal page.find(:id, 'pregnancy_patient_name').value, 'changed'
      fill_in 'First and last name', with: 'more change'
      fill_in 'Phone number', with: @patient.primary_phone
      @patient.reload
      assert_equal @patient.name, 'more change'
      assert_equal @patient.history_tracks.count, 3
      assert_equal @patient.updated_by, @user2
    end
  end
end
