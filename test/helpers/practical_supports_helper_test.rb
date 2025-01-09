require 'test_helper'

class PracticalSupportsHelperTest < ActionView::TestCase
  describe 'practical support options' do
    describe 'with a config' do
      before { create_practical_support_config }

      it 'should include the option set' do
        expected = [
           nil,
          "Metallica Tickets",
          "Clothing",
          ["Travel to the region", "Travel to the region"],
          ["Travel inside the region", "Travel inside the region"],
          ["Lodging", "Lodging"],
          ["Companion", "Companion"],
          ['Other (see notes)', 'Other (see notes)']
        ]
        assert_same_elements expected, practical_support_options
      end

      it 'should not include defaults if configured' do
        create_hide_defaults_config

        expected_custom_options = ['Metallica Tickets', 'Clothing',
                                    ['Other (see notes)', 'Other (see notes)']]
        assert_same_elements expected_custom_options, practical_support_options
      end
    end

    describe 'without a config' do
      before do
        create_hide_defaults_config should_hide: false
      end

      it 'should create a config and return proper options' do
        assert_difference 'Config.count', 1 do
          @options = practical_support_options
        end

        expected = [
          nil,
          ["Travel to the region", "Travel to the region"],
          ["Travel inside the region", "Travel inside the region"],
          ["Lodging", "Lodging"],
          ["Companion", "Companion"],
          ['Other (see notes)', 'Other (see notes)']
        ]
        assert_same_elements expected, @options
        assert Config.find_by(config_key: 'practical_support')
      end
    end

    describe 'with an orphaned value' do
      it 'should push onto the end' do
        expected = [
          nil,
          ["Travel to the region", "Travel to the region"],
          ["Travel inside the region", "Travel inside the region"],
          ["Lodging", "Lodging"],
          ["Companion", "Companion"],
          ['Other (see notes)', 'Other (see notes)'],
          'bandmates'
        ]
        assert_same_elements expected, practical_support_options('bandmates')
      end
    end
  end

  describe 'practical support source options' do
    describe 'with external pledge source config' do
      before { create_external_pledge_source_config }

      it 'should include the option set' do
        expected = [
          nil,
          'Cat Fund',
          'Metallica Abortion Fund',
          'Texas Amalgamated Abortion Services (TAAS)',
          'Cat Town Abortion Fund (CTAF)',
          ['Patient', 'Patient'],
          ['Clinic', 'Clinic'],
          ['Other (see notes)', 'Other (see notes)'],
          ['Not sure yet (see notes)', 'Not sure yet (see notes)']
        ]
        assert_same_elements expected, practical_support_source_options
      end

      it 'should not include defaults if configured' do
        create_hide_defaults_config
        assert_same_elements [nil, 'Cat Fund', 'Metallica Abortion Fund',
                              'Texas Amalgamated Abortion Services (TAAS)',
                              'Cat Town Abortion Fund (CTAF)'], practical_support_source_options
      end
    end

    describe 'without a config' do
      before do
        create_hide_defaults_config should_hide: false
      end
      
      it 'should create a config and return options' do
        assert_difference 'Config.count', 1 do
          @options = practical_support_source_options
        end

        expected = [
          nil,
          'Cat Fund',
          ['Patient', 'Patient'],
          ['Clinic', 'Clinic'],
          ['Other (see notes)', 'Other (see notes)'],
          ['Not sure yet (see notes)', 'Not sure yet (see notes)']
        ]
        assert_same_elements expected, @options
        assert Config.find_by(config_key: 'external_pledge_source')
      end
    end

    describe 'with an orphaned value' do
      it 'should push orphaned value onto the end' do
        expected = [
          nil,
          'Cat Fund',
          ['Patient', 'Patient'],
          ['Clinic', 'Clinic'],
          ['Other (see notes)', 'Other (see notes)'],
          ['Not sure yet (see notes)', 'Not sure yet (see notes)'],
          'yolo'
        ]
        assert_same_elements expected, practical_support_source_options('yolo')
      end
    end
  end

  describe 'practical_support_guidance_link' do
    before do
      @config = create :config, config_key: :practical_support_guidance_url,
                                config_value: { options: ['www.yahoo.com'] }
    end

    it 'should return nil if config is not set' do
      @config.update config_value: { options: [] }
        refute practical_support_guidance_link
      end

    it 'should return a link if config set' do
      expected_link = '<a target="_blank" href="https://www.yahoo.com">CATF practical support guidance</a>'
      assert_equal expected_link, practical_support_guidance_link
    end
  end

  describe 'practical_support_display_text' do
    before do
      @patient = create :patient
      @patient.practical_supports.create support_type: 'Concert Tickets',
                                         source: 'Metallica Abortion Fund'
      @patient.practical_supports.create support_type: 'Swag',
                                         source: 'YOLO AF',
                                         confirmed: true,
                                         support_date: 2.days.from_now,
                                         purchase_date: 1.day.ago
      @patient.practical_supports.create support_type: 'Companion',
                                         source: 'Cat',
                                         amount: 32,
                                         fulfilled: true
      @psupport1 = @patient.practical_supports.first
      @psupport2 = @patient.practical_supports.second
      @psupport3 = @patient.practical_supports.last
    end

    it 'should display' do
      assert_equal 'Concert Tickets from Metallica Abortion Fund', practical_support_display_text(@psupport1)
      assert_equal "(Confirmed) Swag from YOLO AF on #{2.days.from_now.display_date} (Purchased on #{1.day.ago.display_date})", practical_support_display_text(@psupport2)
      assert_equal '(Fulfilled) Companion from Cat for $32.00', practical_support_display_text(@psupport3)
    end
  end
end
