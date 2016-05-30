require 'test_helper'

class PledgeTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @pregnancy = create :pregnancy
    @pledge = create :pledge, pregnancy: @pregnancy, created_by: @user
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @pledge.respond_to? field
        assert @pledge[field]
      end
    end

    it 'should respond to history methods' do
      assert @pledge.respond_to? :history_tracks
      assert @pledge.history_tracks.count > 0 
    end

    it 'should have accessible userstamp methods' do 
      assert @pledge.respond_to? :created_by
      assert @pledge.created_by
    end
  end  
end
