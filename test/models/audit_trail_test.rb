require 'test_helper'

class AuditTrailTest < ActiveSupport::TestCase
  before do 
    @user = create :user
    @patient = create :patient, name: "Susie Everyteen", created_by: @user
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
      # TODO add pregnancy and clinic info 
      assert_equal Patient.tracked_fields, %w(name primary_phone secondary_person secondary_phone updated_by_id)
    end
  end
end
