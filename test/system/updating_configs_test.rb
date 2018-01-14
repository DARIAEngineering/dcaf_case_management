require 'application_system_test_case'

# Confirm behavior around updating fund-editable settings
class UpdatingConfigsTest < ApplicationSystemTestCase
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
      @patient = create :patient
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

        visit edit_patient_path(@patient)
        assert has_select? 'Patient insurance', options: ['', 'Yolo', 'Goat', 'Something',
                                                          'No insurance', "Don't know",
                                                          'Other (add to notes)']
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
          assert has_content? 'Other funds (see notes)'
        end

        visit edit_patient_path(@patient)
        click_link 'Abortion Information'
        assert has_select? 'Source', options: ['', 'Yolo', 'Goat', 'Something',
                                               'Clinic discount',
                                               'Other funds (see notes)']
      end
    end

    describe 'updating a config - Pledge limit help text' do
      it 'should update and be available' do
        fill_in 'config_options_pledge_limit_help_text',
                with: 'Pledge guidelines, 13 weeks $100'
        click_button 'Update options for Pledge limit help text'

        assert_equal 'Pledge guidelines, 13 weeks $100',
                     find('#config_options_pledge_limit_help_text').value
        within :css, '#pledge_limit_help_text_options_list' do
          assert has_content? 'Pledge guidelines'
          assert has_content? '13 weeks $100'
        end

        visit edit_patient_path @patient
        click_link 'Abortion Information'
        find('.tooltip-header-help').hover
        assert has_text? 'Pledge guidelines'
        assert has_text? '13 weeks $100'
      end
    end
  end
end
