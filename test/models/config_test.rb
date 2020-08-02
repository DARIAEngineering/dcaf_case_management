require 'test_helper'

class ConfigTest < ActiveSupport::TestCase
  before { @config = create :config }

  describe 'validations' do
    it 'should build' do
      assert @config.valid?
    end

    it 'should be unique on config_key' do
      @dupe_config = build :config
      refute @dupe_config.valid?
      assert @dupe_config.errors.messages[:config_key].include? 'has already been taken'
    end

    it 'should require a config_key' do
      @bad_config = build :config, config_key: nil
      refute @bad_config.valid?
      assert @bad_config.errors.messages[:config_key].include? "can't be blank"
    end
  end

  describe 'attachments' do
    it 'should respond to history methods' do
      assert @config.respond_to? :versions
      assert @config.respond_to? :created_by
      assert @config.respond_to? :created_by_id
    end
  end

  describe 'methods' do
    it 'should easily retrieve options' do
      assert_equal @config.options,
                   ['DC Medicaid', 'No insurance', "Don't know"]
    end

    it 'should retrieve appropriate help text if set' do
      assert_equal 'Please separate with commas.', @config.help_text

      @config.update config_key: 'resources_url'
      assert_includes @config.help_text,
                      'A link to a Google Drive'
    end
    
    describe 'autosetup' do
      before { Config.destroy_all }

      it 'should create any missing config objects' do
        assert_difference 'Config.count', Config.config_keys.count do
          Config.autosetup
        end

        Config.config_keys.keys.each do |field|
          assert Config.find_by(config_key: field.to_s)
        end
      end

      it 'should only create necessary missing config objects' do
        create_insurance_config

        assert_difference 'Config.count', (Config.config_keys.count - 1) do
          Config.autosetup
        end

        Config.config_keys.keys.each do |field|
          assert Config.find_by(config_key: field.to_s)
        end
      end
    end

    describe '#budget_bar_max' do
      it 'should return an integer of 1_000 if unconfigured' do
        assert_equal 1_000, Config.budget_bar_max
      end

      it 'should return another amount if configured' do
        c = Config.find_or_create_by(config_key: 'budget_bar_max')
        c.config_value = { options: [2000] }
        c.save!
        assert_equal 2_000, Config.budget_bar_max
      end
    end

    describe '#hide_practical_support?' do
      it 'can return true' do
        c = Config.find_or_create_by(config_key: 'hide_practical_support')
        c.config_value = { options: ["Yes"] }
        c.save!
        assert(Config.hide_practical_support? == true)
      end

      it 'can return false' do
        c = Config.find_or_create_by(config_key: 'hide_practical_support')
        c.config_value = { options: ["No"] }
        c.save!
        assert(Config.hide_practical_support? == false)
      end

      it "returns false by default" do
        assert(Config.hide_practical_support? == false)
      end
    end

    describe '#start_day' do
      it 'should return the day of week as a symbol' do
        assert_equal :monday, Config.start_day
      end

      it 'should return another day of the week if configured' do
        c = Config.find_or_create_by(config_key: 'start_of_week')
        c.config_value = { options: ["Tuesday"] }
        c.save!
        assert_equal :tuesday, Config.start_day
      end
    end
  end
end
