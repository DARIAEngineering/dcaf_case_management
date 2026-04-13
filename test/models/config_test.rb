require 'test_helper'

class ConfigTest < ActiveSupport::TestCase
  before { @config = create :config }

  describe 'callbacks' do
    it 'should capitalize words before save' do
      c = Config.find_or_create_by(config_key: :start_of_week)
      c.config_value= { options: ["wednesday"] }
      assert c.valid?
      assert_equal "Wednesday", c.options.last

      c = Config.find_or_create_by(config_key: :hide_practical_support)
      c.config_value = { options: ["no"] }
      assert c.valid?
      assert_equal "No", c.options.last
    end

    it 'should titleize words before save' do
      c = Config.find_or_create_by(config_key: :time_zone)
      c.config_value= { options: ["puerto rico"] }
      assert c.valid?
      assert_equal "Puerto Rico", c.options.last
    end
  end

  describe 'validations' do
    it 'should build' do
      assert @config.valid?
    end

    it 'should be unique on config_key' do
      @dupe_config = build :config
      refute @dupe_config.valid?
      assert @dupe_config.errors.messages[:config_key].include? 'has already been taken'
    end

    it 'should enforce config_key uniqueness at the DB level' do
      @dupe_config = build :config
      assert_raises ActiveRecord::RecordNotUnique do
        @dupe_config.save!(validate: false)
      end
    end

    it 'should require a config_key' do
      @bad_config = build :config, config_key: nil
      refute @bad_config.valid?
      assert @bad_config.errors.messages[:config_key].include? "can't be blank"
    end

    it 'should reject lists for singleton values' do
      c = Config.find_or_create_by(config_key: :start_of_week)

      c.config_value = { options: ["monday", "friday"] }
      refute c.valid?

      c = Config.find_or_create_by(config_key: :budget_bar_max)

      c.config_value = { options: ["1000", "2000"] }
      refute c.valid?

      c = Config.find_or_create_by(config_key: :time_zone)

      c.config_value = { options: ["Eastern", "Pacific"] }
      refute c.valid?
    end

    it 'should allow lists for non-singleton values' do
      c = Config.find_or_create_by(config_key: :practical_support)

      c.config_value = { options: ["car", "train"] }
      assert c.valid?
    end

    it 'should validate URLs' do
      Config::VALIDATIONS
        .select{ |field, validator| validator == :validate_url }
        .each do |url_field, _validator|
          c = Config.find_or_create_by(config_key: url_field)
          
          # confirm cleaned URLs still valid
          c.config_value = { options: ["www.efax.com/path"] }
          assert c.valid?
          # confirm https was added
          assert_equal "https://www.efax.com/path", c.options.last.to_s

          # bad
          c.config_value = { options: ["bad url"] }
          refute c.valid?

          # allow no URL
          c.config_value = { options: [] }
          assert c.valid?

          # make sure this is left alone
          assert_nil c.options.last
      end
    end

    it 'should validate start of week' do
      c = Config.find_or_create_by(config_key: :start_of_week)

      c.config_value = { options: ["random value"] }
      refute c.valid?

      c.config_value = { options: ["weekly"] }
      refute c.valid?

      c.config_value = { options: ["monday"] }
      assert c.valid?
      
      c.config_value = { options: ["Wednesday"] }
      assert c.valid?
      
      c.config_value = { options: ["monthly"] }
      assert c.valid?
    end

    it 'should validate time zone' do
      c = Config.find_or_create_by(config_key: :time_zone)

      c.config_value = { options: ["random value"] }
      refute c.valid?

      c.config_value = { options: ["American Samoa"] }
      refute c.valid?

      c.config_value = { options: ["eastern"] }
      assert c.valid?
      
      c.config_value = { options: ["Pacific"] }
      assert c.valid?
      
      c.config_value = { options: ["indiana (east)"] }
      assert c.valid?
    end
  end

  describe 'history' do
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
        assert_difference 'Config.count', Config.config_keys.keys.count do
          Config.autosetup
        end

        Config.config_keys.keys.each do |field|
          assert Config.find_by(config_key: field.to_s)
        end
      end

      it 'should only create necessary missing config objects' do
        create_insurance_config

        assert_difference 'Config.count', (Config.config_keys.keys.count - 1) do
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
        c.config_value = { options: ["2000"] }
        c.save!
        assert_equal 2_000, Config.budget_bar_max
      end
    end

    describe 'archive_patients' do
      it 'should return proper defaults' do
        assert_equal Config::DEFAULTS[:days_to_keep_fulfilled_patients], Config.archive_fulfilled_patients
        assert_equal Config::DEFAULTS[:days_to_keep_all_patients], Config.archive_all_patients
      end

      it 'should validate bounds' do
        c = Config.find_or_create_by(config_key: 'days_to_keep_all_patients')
        
        # low out of bounds
        c.config_value = { options: ["59"] }
        refute c.valid?
        
        # low edge
        c.config_value = { options: ["60"] }
        assert c.valid?
        
        # in bounds
        c.config_value = { options: ["120"] }
        assert c.valid?
        
        # high edge
        c.config_value = { options: ["550"] }
        assert c.valid?
        
        c.config_value = { options: ["551"] }
        refute c.valid?
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

    describe '#hide_budget_bar?' do
      it 'can return true' do
        c = Config.find_or_create_by(config_key: 'hide_budget_bar')
        c.config_value = { options: ["Yes"] }
        c.save!
        assert(Config.hide_budget_bar? == true)
      end

      it 'can return false' do
        c = Config.find_or_create_by(config_key: 'hide_budget_bar')
        c.config_value = { options: ["No"] }
        c.save!
        assert(Config.hide_budget_bar? == false)
      end

      it "returns false by default" do
        assert(Config.hide_budget_bar? == false)
      end
    end

    describe '#display_practical_support_attachment_url?' do
      it 'can return true' do
        c = Config.find_or_create_by(config_key: 'display_practical_support_attachment_url')
        c.config_value = { options: ["Yes"] }
        c.save!
        assert(Config.display_practical_support_attachment_url? == true)
      end

      it 'can return false' do
        c = Config.find_or_create_by(config_key: 'display_practical_support_attachment_url')
        c.config_value = { options: ["No"] }
        c.save!
        assert(Config.display_practical_support_attachment_url? == false)
      end

      it "returns false by default" do
        assert(Config.display_practical_support_attachment_url? == false)
      end
    end

    describe '#display_practical_support_waiver?' do
      it 'can return true' do
        c = Config.find_or_create_by(config_key: 'display_practical_support_waiver')
        c.config_value = { options: ["Yes"] }
        c.save!
        assert(Config.display_practical_support_waiver? == true)
      end

      it 'can return false' do
        c = Config.find_or_create_by(config_key: 'display_practical_support_waiver')
        c.config_value = { options: ["No"] }
        c.save!
        assert(Config.display_practical_support_waiver? == false)
      end

      it "returns false by default" do
        assert(Config.display_practical_support_waiver? == false)
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

    describe '#time_zone' do
      it 'should return the time zone as an ActiveSupport::TimeZone' do
        assert_equal ActiveSupport::TimeZone.new("Eastern Time (US & Canada)"), Config.time_zone
      end

      it 'should return another time zone if configured' do
        c = Config.find_or_create_by(config_key: 'time_zone')
        c.config_value = { options: ["Mountain"] }
        c.save!
        assert_equal ActiveSupport::TimeZone.new("Mountain Time (US & Canada)"), Config.time_zone
      end
    end

    describe 'shared_reset_days' do
      it 'should return proper default' do
        assert_equal Config::DEFAULTS[:shared_reset_days], Config.shared_reset_days
      end

      it 'should validate bounds' do
        c = Config.find_or_create_by(config_key: 'shared_reset_days')

        # low out of bounds
        c.config_value = { options: ["1"] }
        refute c.valid?

        # low edge
        c.config_value = { options: ["2"] }
        assert c.valid?

        # in bounds
        c.config_value = { options: ["14"] }
        assert c.valid?

        # high edge
        c.config_value = { options: ["42"] }
        assert c.valid?

        c.config_value = { options: ["43"] }
        refute c.valid?
      end
    end

  end

  describe 'session_timeout' do
    it 'should have enum value 26' do
      assert_equal 26, Config.config_keys['session_timeout']
    end

    it 'should return default 30 minutes when no tenant is set' do
      ActsAsTenant.without_tenant do
        assert_equal 30.minutes, Config.session_timeout
      end
    end

    it 'should return configured timeout value when tenant is set' do
      c = Config.find_or_create_by(config_key: 'session_timeout')
      c.config_value = { options: ["60"] }
      c.save!
      assert_equal 60.minutes, Config.session_timeout
    end

    it 'should fall back to default for invalid timeout values' do
      c = Config.find_or_create_by(config_key: 'session_timeout')
      c.config_value = { options: ["999"] }
      c.save!(validate: false)
      assert_equal 30.minutes, Config.session_timeout
    end

    it 'should accept all valid timeout options' do
      [15, 30, 60, 120, 180].each do |minutes|
        c = Config.find_or_create_by(config_key: 'session_timeout')
        c.config_value = { options: [minutes.to_s] }
        c.save!
        assert_equal minutes.minutes, Config.session_timeout
      end
    end

    it 'should validate session_timeout values' do
      c = Config.find_or_create_by(config_key: 'session_timeout')

      c.config_value = { options: ["30"] }
      assert c.valid?

      c.config_value = { options: ["60"] }
      assert c.valid?

      c.config_value = { options: ["45"] }
      refute c.valid?

      c.config_value = { options: ["0"] }
      refute c.valid?
    end

    it 'should have default value of 30' do
      assert_equal 30, Config::DEFAULTS[:session_timeout]
    end

    it 'should be used by User#timeout_in for dynamic session timeout' do
      user = create :user
      c = Config.find_or_create_by(config_key: 'session_timeout')
      c.config_value = { options: ["120"] }
      c.save!
      assert_equal 120.minutes, user.timeout_in
    end

    it 'should have session store configured with security attributes' do
      store_config = Rails.application.config.session_options
      assert_equal true, store_config[:httponly]
      assert_equal :lax, store_config[:same_site]
    end

    describe 'cross-fund isolation' do
      it 'should not leak timeout config from one fund to another' do
        # Configure timeout for current tenant
        c = Config.find_or_create_by(config_key: 'session_timeout')
        c.config_value = { options: ["120"] }
        c.save!
        assert_equal 120.minutes, Config.session_timeout

        # Switch to a different tenant
        other_fund = create :fund, name: 'OtherFund', full_name: 'Other Fund'
        ActsAsTenant.current_tenant = other_fund
        ActsAsTenant.test_tenant = other_fund

        # The other fund should get the default, not fund 1's value
        assert_equal 30.minutes, Config.session_timeout
      end
    end

    describe 'missing config record' do
      it 'should return default timeout when config record does not exist' do
        Config.where(config_key: 'session_timeout').destroy_all
        assert_equal 30.minutes, Config.session_timeout
      end

      it 'should return default timeout when config record has nil options' do
        c = Config.find_or_create_by(config_key: 'session_timeout')
        c.update_columns(config_value: { 'options' => [nil] })
        assert_equal 30.minutes, Config.session_timeout
      end
    end

    describe 'User#timeout_in' do
      it 'should return an ActiveSupport::Duration' do
        user = create :user
        result = user.timeout_in
        assert_kind_of ActiveSupport::Duration, result
      end

      it 'should reflect the configured session timeout' do
        c = Config.find_or_create_by(config_key: 'session_timeout')
        c.config_value = { options: ["60"] }
        c.save!

        user = create :user
        assert_equal 60.minutes, user.timeout_in
        assert_equal 3600, user.timeout_in.to_i
      end

      it 'should return default 30 minutes when unconfigured' do
        Config.where(config_key: 'session_timeout').destroy_all
        user = create :user
        assert_equal 30.minutes, user.timeout_in
      end
    end
  end
end
