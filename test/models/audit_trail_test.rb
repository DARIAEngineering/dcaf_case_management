require 'test_helper'

class AuditTrailTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, name: 'Susie Everyteen',
                                primary_phone: '111-222-3333',
                                appointment_date: DateTime.now.utc + 5.days,
                                initial_call_date: DateTime.now.utc + 3.days,
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
                                 appointment_date: DateTime.now.utc + 10.days,
                                 initial_call_date: DateTime.now.utc + 4.days
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
                     (DateTime.now.in_time_zone("UTC") + 5.days).display_date,
                     (DateTime.now.in_time_zone("UTC") + 3.days).display_date,
                     "D2-3333"]
    end

    it 'should conveniently render what they areTime now' do
      assert_equal @track.changed_to,
                  ["Yolo",
                    "1234569999",
                    (DateTime.now.in_time_zone("UTC") + 10.days).display_date,
                    (DateTime.now.in_time_zone("UTC") + 4.days).display_date,
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
