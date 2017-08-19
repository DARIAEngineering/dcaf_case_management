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
      @dupe_config = build :config
      refute @dupe_config.valid?
      assert @dupe_config.errors.messages[:config_key].include? 'is already taken'
    end

    it 'should require a config_key' do
      @bad_config = build :config, config_key: nil
      refute @bad_config.valid?
      assert @bad_config.errors.messages[:config_key].include? "can't be blank"
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

  describe 'methods' do
    it 'should easily retrieve options' do
      assert_equal @config.options,
                   ['DC Medicaid', 'No insurance', "Don't know"]
    end

    describe 'autosetup' do
      before { Config.destroy_all }

      it 'should create any missing config objects' do
        assert_difference 'Config.count', Config::CONFIG_FIELDS.count do
          Config.autosetup
        end

        Config::CONFIG_FIELDS.each do |field|
          assert Config.find_by(config_key: field.to_s)
        end
      end

      it 'should only create necessary missing config objects' do
        create_insurance_config

        assert_difference 'Config.count', (Config::CONFIG_FIELDS.count - 1) do
          Config.autosetup
        end

        Config::CONFIG_FIELDS.each do |field|
          assert Config.find_by(config_key: field.to_s)
        end
      end
    end
  end
end
