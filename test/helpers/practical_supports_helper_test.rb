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
    end

    describe 'without a config' do
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
          'DC Abortion Fund',
          'Baltimore Abortion Fund',
          'Tiller Fund (NNAF)',
          'NYAAF (New York)',
          ['Patient', 'Patient'],
          ['Clinic', 'Clinic'],
          ['Other (see notes)', 'Other (see notes)'],
          ['Not sure yet (see notes)', 'Not sure yet (see notes)']
        ]
        assert_same_elements expected, practical_support_source_options
      end
    end

    describe 'without a config' do
      it 'should create a config and return options' do
        assert_difference 'Config.count', 1 do
          @options = practical_support_source_options
        end

        expected = [
          nil,
          'DC Abortion Fund',
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
          'DC Abortion Fund',
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
                                config_value: { options: ['https://www.yahoo.com'] }
    end

    it 'should return nil if config is not set' do
      @config.update config_value: { options: [] }
        refute practical_support_guidance_link
      end

    it 'should return a link if config set' do
      expected_link = '<small class="pull-right"><a target="_blank" href="https://www.yahoo.com">DCAF practical support guidance</a></small>'
      assert_equal expected_link, practical_support_guidance_link
    end
  end
end
