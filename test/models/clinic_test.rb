require 'test_helper'

class ClinicTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @clinic = create :clinic, created_by: @user
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @clinic.respond_to? field
        assert @clinic[field]
      end
    end

    it 'should respond to history methods' do
      assert @clinic.respond_to? :history_tracks
      assert @clinic.history_tracks.count > 0
    end

    it 'should have accessible userstamp methods' do
      assert @clinic.respond_to? :created_by
      assert @clinic.created_by
    end
  end
end
