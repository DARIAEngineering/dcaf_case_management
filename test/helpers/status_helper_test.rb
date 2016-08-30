require 'test_helper'

class StatusHelperTest < ActionView::TestCase
  before do
    @user = create :user
    @patient = create :patient, other_phone: '111-222-3333',
                                other_contact: 'Yolo'
    @pregnancy = create :pregnancy, patient: @patient
  end

  describe 'status method' do
    it 'should default to "No Contact Made" when a patient has no calls' do
      assert_equal Patient::STATUSES[:no_contact], @patient.status
    end

    it 'should default to "No Contact Made" on a patient left voicemail' do
      create :call, patient: @patient, status: 'Left voicemail'
      assert_equal Patient::STATUSES[:no_contact], @patient.status
    end

    it 'should update to "Needs Appointment" once patient has been reached' do
      create :call, patient: @patient, status: 'Reached patient'
      assert_equal Patient::STATUSES[:needs_appt], @patient.status
    end

    it 'should update to "Fundraising" once an appointment has been made' do
      @patient.appointment_date = '01/01/2017'
      assert_equal Patient::STATUSES[:fundraising], @patient.status
    end

    it 'should update to "Sent Pledge" after a pledge has been sent' do
      @patient.pregnancy.pledge_sent = true
      assert_equal Patient::STATUSES[:pledge_sent], @patient.status
    end

    # it 'should update to "Pledge Paid" after a pledge has been paid' do
    # end

    it 'should update to "Resolved Without DCAF" if patient is resolved' do
      @patient.pregnancy.resolved_without_dcaf = true
      assert_equal Patient::STATUSES[:resolved], @patient.status
    end
  end

  describe 'contact_made? method' do
    it 'should return false if no calls have been made' do
      refute @patient.send :contact_made?
    end

    it 'should return false if an unsuccessful call has been made' do
      create :call, patient: @patient, status: 'Left voicemail'
      refute @patient.send :contact_made?
    end

    it 'should return true if a successful call has been made' do
      create :call, patient: @patient, status: 'Reached patient'
      assert @patient.send :contact_made?
    end
  end
end
