require 'test_helper'

class AuditTrailTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, name: 'Susie Everyteen', primary_phone: '111-222-3333', created_by: @user
  end

  describe 'natural initializing - everything okay alarm' do
    it 'should be available on a patient creation' do
      assert_not_nil @patient.history_tracks
      assert_kind_of AuditTrail, @patient.history_tracks.first
    end

    it 'should record the creating user' do
      assert_equal @patient.created_by, @user
    end

    it 'should track proper info' do
      # TODO: add pregnancy and clinic info
      assert_equal Patient.tracked_fields, %w(name primary_phone secondary_person secondary_phone updated_by_id)
    end
  end

  describe 'methods' do
    before do
      @patient.update_attributes name: 'Yolo', primary_phone: '123-456-9999'
      @track = @patient.history_tracks.second
    end

    it 'should conveniently render changed fields' do
      assert_equal @track.tracked_changes_fields, 'Name<br>Primary phone'
    end

    it 'should conveniently render what they were before' do
      assert_equal @track.tracked_changes_from, 'Susie Everyteen<br>111-222-3333'
    end

    it 'should conveniently render what they are now' do
      assert_equal @track.tracked_changes_to, 'Yolo<br>123-456-9999'
    end
  end
end
