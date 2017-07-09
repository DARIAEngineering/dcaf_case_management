require 'test_helper'

class UpdatingConfigsTest < ActionDispatch::IntegrationTest
  describe 'non-admin redirect' do
    [:data_volunteer, :cm].each do |role|
      it "should deny access as a #{role.to_s}" do
        user = create :user, role: role
        log_in_as user
        visit configs_path
        assert_equal current_path, authenticated_root_path
      end
    end
  end

  describe 'admin usage' do
    before do
      @config = create :config
      @config = create :config, config_key: :external_pledge_source
      @user = create :user, role: :admin
      log_in_as @user
      visit configs_path
    end

    describe 'updating a config - insurance' do
      it 'should update and be available' do
        fill_in 'config_options_insurance', with: 'Yolo, Goat, Something'
        click_button 'Update options for Insurance'

        assert_equal 'Yolo, Goat, Something',
                     find('#config_options_insurance').value
        within :css, '#insurance_options_list' do
          assert has_content? 'Yolo'
          assert has_content? 'Goat'
          assert has_content? 'Something'
          assert has_content? 'No insurance'
          assert has_content? "Don't know"
          assert has_content? 'Other (add to notes)'
        end
      end
    end

    describe 'updating a config - external pledge' do
      it 'should update and be available' do
        fill_in 'config_options_external_pledge_source', with: 'Yolo, Goat, Something'
        click_button 'Update options for External pledge source'

        assert_equal 'Yolo, Goat, Something',
                     find('#config_options_external_pledge_source').value
        within :css, '#external_pledge_source_options_list' do
          assert has_content? 'Yolo'
          assert has_content? 'Goat'
          assert has_content? 'Something'
          assert has_content? 'Clinic discount'
          assert has_content? 'Other fund (see notes)'
        end
      end
    end
  end
end
