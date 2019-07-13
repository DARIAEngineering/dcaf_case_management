require 'test_helper'

class PracticalSupportsHelperTest < ActionView::TestCase
  describe 'practical support options' do
    describe 'with a config' do
      before { create_practical_support_config }

      it 'should include the option set' do
        expected_practical_support_options_array = [ nil,
                                                     "Metallica Tickets",
                                                     "Clothing",
                                                     ["Travel to the region", "Travel to area"],
                                                     ["Travel inside the region", "Travel inside area"],
                                                     ["Lodging", "Lodging"],
                                                     ["Companion", "Companion"]]
        assert_same_elements practical_support_options, expected_practical_support_options_array
      end
    end

    describe 'without a config' do
      it 'should create a config and return proper options' do
        assert_difference 'Config.count', 1 do
          @options = practical_support_options
        end

        expected_practical_support_array = [ nil,
                                             ["Travel to the region", "Travel to area"],
                                             ["Travel inside the region", "Travel inside area"],
                                             ["Lodging", "Lodging"],
                                             ["Companion", "Companion"]]
        assert_same_elements @options, expected_practical_support_array
        assert Config.find_by(config_key: 'practical_support')
      end
    end

    describe 'with an orphaned value' do
      it 'should push onto the end' do
        expected = [ nil,
                     ["Travel to the region", "Travel to area"],
                     ["Travel inside the region", "Travel inside area"],
                     ["Lodging", "Lodging"],
                     ["Companion", "Companion"],
                     'bandmates' ]
        assert_same_elements expected, practical_support_options('bandmates')
      end
    end
  end

  describe 'practical support source options' do
    describe 'using external pledge source config'
  end
end
