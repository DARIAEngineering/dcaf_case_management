require 'test_helper'

class ConfigTest < ActiveSupport::TestCase
  before do
    @config = create :config
  end

  describe 'validations' do
    it 'should build' do
      assert @config.valid?
    end

    it 'should be unique on config_key' do
      assert true
    end

    it 'should require a user id' do
      @config.created_by = nil
      refute @config.valid?
    end
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @config.respond_to? field
        assert @config[field]
      end
    end

    it 'should respond to history methods' do
      assert @config.respond_to? :history_tracks
      assert @config.history_tracks.count > 0
    end

    it 'should have accessible userstamp methods' do
      assert @config.respond_to? :created_by
      assert @config.created_by
    end
  end
end
