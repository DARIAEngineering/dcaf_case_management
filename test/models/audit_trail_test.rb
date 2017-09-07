require 'test_helper'

class AuditTrailTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, name: 'Susie Everyteen',
                                primary_phone: '111-222-3333',
                                appointment_date: 5.days.from_now,
                                initial_call_date: 3.days.ago,
                                created_by: @user
  end

  describe 'natural initializing - everything okay alarm' do
    it 'should be available on a patient creation' do
      assert_not_nil @patient.history_tracks
      assert_kind_of AuditTrail, @patient.history_tracks.first
    end

    it 'should record the creating user' do
      assert_equal @patient.created_by, @user
    end
  end

  describe 'methods' do
    before do
      @patient.update_attributes name: 'Yolo',
                                 primary_phone: '123-456-9999',
                                 appointment_date: 10.days.from_now,
                                 initial_call_date: 4.days.ago
      @track = @patient.history_tracks.second
    end

    it 'should conveniently render the date' do
      assert_equal Time.zone.now.display_date,
                   @track.date_of_change
    end


    it 'should conveniently render changed fields' do
      assert_equal @track.changed_fields,
                   ["Name", "Primary phone", "Appointment date", "Initial call date", "Identifier"]
    end

    it 'should conveniently render what they were before' do
      assert_equal @track.changed_from,
                   ["Susie Everyteen",
                     "1112223333",
                     5.days.from_now.strftime('%m/%d/%Y'),
                     3.days.ago.strftime('%m/%d/%Y'),
                     "D2-3333"]
    end

    it 'should conveniently render what they are now' do
      assert_equal @track.changed_to,
                  ["Yolo",
                    "1234569999",
                    10.days.from_now.strftime('%m/%d/%Y'),
                    4.days.ago.strftime('%m/%d/%Y'),
                    "D6-9999"]
    end

    it 'should default to System if it cannot find a user' do
      assert_equal @track.changed_by_user, 'System'
    end

  end

  describe 'marked urgent' do
    it 'should return true if urgent flag was changed to true' do
      @patient = create :patient
      @patient.urgent_flag = true
      @patient.save

      assert @patient.history_tracks.second.marked_urgent?
    end
  end
end
