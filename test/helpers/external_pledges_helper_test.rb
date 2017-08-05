require 'test_helper'

class ExternalPledgesHelperTest < ActionView::TestCase
  describe 'options generators' do
    before do
      create :config, config_key: 'external_pledge_source',
                      config_value: { options: ['Baltimore Abortion Fund', 'Tiller Fund (NNAF)', 'NYAAF (New York)'] }
      @options = external_pledge_source_options
    end

    it 'should spit out an array of available other funds' do
      assert_includes @options, 'Baltimore Abortion Fund'
      assert @options.class == Array
    end

    it 'should include the whole list of options' do
      expected_external_pledges_array = ["Baltimore Abortion Fund",
        "Tiller Fund (NNAF)",
        "NYAAF (New York)",
        "Clinic discount",
        "Other funds (see notes)"]
      assert_same_elements @options, expected_external_pledges_array
    end

    it 'should remove preselected options' do
      @patient = create :patient
      create :external_pledge, source: 'Baltimore Abortion Fund',
                               amount: 100,
                               patient: @patient

      refute_includes available_pledge_source_options_for(@patient),
                      'Baltimore Abortion Fund'
      assert_includes available_pledge_source_options_for(@patient),
                      'NYAAF (New York)'
    end
  end

  describe 'creating a config object if one does not exist yet' do
    it 'should do that, with a properly set key' do
      assert_difference 'Config.count', 1 do
        @options = external_pledge_source_options
      end

      expected_external_pledges_array = ['Clinic discount',
                                         'Other funds (see notes)']
      assert_same_elements @options, expected_external_pledges_array

      assert Config.find_by(config_key: 'external_pledge_source')
    end
  end
end
