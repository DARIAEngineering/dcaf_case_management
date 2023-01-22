require 'test_helper'

class ExternalPledgesHelperTest < ActionView::TestCase
  describe 'options generators' do
    before do
      create_external_pledge_source_config
      @options = external_pledge_source_options
    end

    it 'should spit out an array of available other funds' do
      assert_includes @options, 'Metallica Abortion Fund'
      assert @options.class == Array
    end

    it 'should include the whole list of options' do
      expected_external_pledges_array = [
        'Metallica Abortion Fund',
        'Texas Amalgamated Abortion Services (TAAS)',
        'Cat Town Abortion Fund (CTAF)',
        ["Clinic discount", "Clinic discount"],
        ["Other funds (see notes)","Other funds (see notes)"]]
      assert_same_elements @options, expected_external_pledges_array
    end

    it 'should remove preselected options' do
      @patient = create :patient

      @patient.external_pledges.create source: 'Metallica Abortion Fund',
                                       amount: 100

      refute_includes available_pledge_source_options_for(@patient),
                      'Metallica Abortion Fund'
      assert_includes available_pledge_source_options_for(@patient),
                      'Cat Town Abortion Fund (CTAF)'
    end

    it 'should not include defaults if configured' do
      create_hide_defaults_config
      assert_same_elements ['Metallica Abortion Fund',
                            'Texas Amalgamated Abortion Services (TAAS)',
                            'Cat Town Abortion Fund (CTAF)'], external_pledge_source_options
    end
  end

  describe 'creating a config object if one does not exist yet' do
    before do
      create_hide_defaults_config should_hide: false
    end

    it 'should do that, with a properly set key' do
      assert_difference 'Config.count', 1 do
        @options = external_pledge_source_options
      end

      expected_external_pledges_array = [["Clinic discount", "Clinic discount"],
                                         ["Other funds (see notes)","Other funds (see notes)"]]
      assert_same_elements expected_external_pledges_array, @options

      assert Config.find_by(config_key: 'external_pledge_source')
    end
  end
end
