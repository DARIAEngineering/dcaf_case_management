require 'application_system_test_case'

# Confirm behavior around updating fund-editable settings
class UpdatingConfigsTest < ApplicationSystemTestCase
  describe 'non-admin redirect' do
    [:data_volunteer, :cm].each do |role|
      it "should deny access as a #{role.to_s}" do
        user = create :user, role: role
        create :line
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
                                                          'Prefer not to answer',
                                                          'Other (add to notes)']
      end
    end

    describe 'updating voicemail config' do
      it 'should update and be available' do
        # add the options
        fill_in 'config_options_voicemail', with: 'Text, Code, Business'
        click_button 'Update options for Voicemail'

        # make sure they persist
        assert_equal 'Text, Code, Business',
                     find('#config_options_voicemail').value
        within :css, '#voicemail_options_list' do
          assert has_content? 'Text'
          assert has_content? 'Code'
          assert has_content? 'Business'
        end

        # make sure they're available in the dropdown
        visit edit_patient_path(@patient)
        assert has_select? 'Voicemail preference', options:
          ['No instructions; no ID VM',
           'Do not leave a voicemail',
           'Voicemail OK, ID OK',
           'Text',
           'Code',
           'Business'
          ]
      end
    end

    describe 'updating a config - practical support' do
      it 'should update and be available' do
        fill_in 'config_options_practical_support', with: 'Yolo, Goat, Something'
        click_button 'Update options for Practical support'

        assert_equal 'Yolo, Goat, Something',
                     find('#config_options_practical_support').value
        within :css, '#practical_support_options_list' do
          assert has_content? 'Yolo'
          assert has_content? 'Goat'
          assert has_content? 'Something'
          assert has_content? 'Travel to the region'
          assert has_content? 'Travel inside the region'
          assert has_content? "Lodging"
          assert has_content? 'Companion'
        end

        # Requires view implementation
        #visit edit_patient_path(@patient)
        #assert has_select? 'Patient insurance', options: ['', 'Yolo', 'Goat', 'Something',
                                                          #'No insurance', "Don't know",
                                                          #'Other (add to notes)']
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

        # Can't get this to work quite right
        # visit edit_patient_path @patient
        # click_link 'Abortion Information'
        # within :css, 'label[for=patient_fund_pledge]' do
        #   find('.tooltip-header-help').hover
        # end
        # assert has_text? 'Pledge guidelines'
        # assert has_text? '13 weeks $100'
      end
    end

    describe 'updating a config - referred by' do
      it 'should update and be available' do
        fill_in 'config_options_referred_by', with: 'Metallica'
        click_button 'Update options for Referred by'

        assert_equal 'Metallica',
                     find('#config_options_referred_by').value
        within :css, '#referred_by_options_list' do
          assert has_content? 'Clinic' # stock option
          assert has_content? 'Metallica' # custom option
        end
      end
    end

    describe 'updating a config - fax service' do
      it 'should update and be available in the footer' do
        fill_in 'config_options_fax_service', with: 'metallicarules.com'
        click_button 'Update options for Fax service'

        assert_equal 'https://metallicarules.com',
                     find('#config_options_fax_service').value
        within :css, '#app_footer' do
          assert has_content? 'https://metallicarules.com'
        end
      end

      it 'should reject invalid values' do
        # first, put in a good value
        fill_in 'config_options_fax_service', with: 'catfax.net'
        click_button 'Update options for Fax service'

        assert_equal 'https://catfax.net',
                     find('#config_options_fax_service').value
        within :css, '#app_footer' do
          assert has_content? 'https://catfax.net'
        end

        # attempt to fill in a bad one
        fill_in 'config_options_fax_service', with: 'invalid fax service.com'
        click_button 'Update options for Fax service'

        within :css, '#flash_alert' do
          assert has_content? 'Config failed to update - Invalid value for fax service'
        end

        # confirm no change
        within :css, '#app_footer' do
          assert has_content? 'https://catfax.net'
        end
      end
    end

    describe 'updating a config - hide budget bar' do
      it 'should toggle the budget bar on the dashboard' do
        fill_in 'config_options_hide_budget_bar', with: 'yes'
        click_button 'Update options for Hide budget bar'
        visit authenticated_root_path
        refute has_content? 'Budget for'

        visit configs_path
        fill_in 'config_options_hide_budget_bar', with: ''
        click_button 'Update options for Hide budget bar'        
        visit authenticated_root_path
        within :css, '#overview' do
          assert has_content? 'Budget for'
        end
      end
    end

    describe 'updating a config - display_practical_support_attachment_url' do
      before do
        @patient = create :patient
        @patient.practical_supports.create attributes_for :practical_support
      end

      it 'should toggle the display of attachment_url' do
        fill_in 'config_options_display_practical_support_attachment_url', with: 'no'
        click_button 'Update options for Display practical support attachment url'
        visit edit_patient_path @patient
        click_link 'Practical Support'
        refute has_content? 'Attachment URL'

        visit configs_path
        fill_in 'config_options_display_practical_support_attachment_url', with: 'yes'
        click_button 'Update options for Display practical support attachment url'
        visit edit_patient_path @patient
        click_link 'Practical Support'
        assert has_content? 'Attachment URL'
      end
    end

    describe 'updating a config - aggregate statistics' do
      it 'should toggle aggregate statistics on budget bar' do
        fill_in 'config_options_aggregate_statistics', with: 'yes'
        click_button 'Update options for Aggregate statistics'
        visit authenticated_root_path
        within :css, "#overview" do
          assert has_content? "$0 spent (0 patients, 0%)"
          assert has_content? "$1,000 remaining (100%)"
        end

        visit configs_path
        fill_in 'config_options_aggregate_statistics', with: 'no'
        click_button 'Update options for Aggregate statistics'
        visit authenticated_root_path
        within :css, "#overview" do
          refute has_content? "spent"
          refute has_content? "remaining"
        end
      end
    end

    describe 'updating a config - county' do
      it 'should display dropdown if counties specified and retain previous' do
        @patient.county = 'Bird'
        @patient.save!

        fill_in 'config_options_county', with: 'Dog, Cat, Turtle'
        click_button 'Update options for County'
        
        visit edit_patient_path @patient

        within :css, "#patient_information_form" do
          assert has_select? with_options: %w[Dog Cat Turtle Bird],
                             selected: 'Bird'
        end
      end

      it 'should keep current value when config removed' do
        @patient.county = 'Bear'
        @patient.save!

        # no config, so we should get a text box
        fill_in 'config_options_county', with: ''
        click_button 'Update options for County'
        
        visit edit_patient_path @patient

        within :css, "#patient_information_form" do
          assert has_field? type: 'text', with: 'Bear'
        end
      end
    end

    describe 'updating a config - procedure_type' do
      it 'should display dropdown if procedure types are specified' do
        fill_in 'config_options_procedure_type', with: 'Dog, Cat, Turtle'
        click_button 'Update options for Procedure type'

        @patient.procedure_type = 'Dog'
        @patient.save!

        visit edit_patient_path @patient
        click_link 'Abortion Information'

        within :css, "#abortion-information-form-1" do
          assert has_select? with_options: %w[Dog Cat Turtle],
                             selected: 'Dog'
        end
      end

      it 'should hide the dropdown when config removed' do
        # no config, so we should get a text box
        fill_in 'config_options_procedure_type', with: ''
        click_button 'Update options for Procedure type'

        visit edit_patient_path @patient
        click_link 'Abortion Information'

        within :css, "#abortion-information-form-1" do
          refute has_content? 'Procedure type'
        end
      end
    end

    describe 'updating a config - procedure_type' do
      it 'should display dropdown if procedure types are specified' do
        fill_in 'config_options_consent_to_survey', with: 'yes'
        click_button 'Update options for Consent to survey'

        @patient.procedure_type = 'Dog'
        @patient.save!

        visit edit_patient_path @patient
        click_link 'Patient Information'

        within :css, "#abortion-information-form-1" do
          assert has_checkbox with_options: 'Consent to survey'
        end
      end

      it 'should hide the dropdown when config removed' do
        # no config, so we should get a text box
        fill_in 'config_options_consent_to_survey', with: ''
        click_button 'Update options for Consent to survey'

        visit edit_patient_path @patient
        click_link 'Patient Information'

        within :css, "#abortion-information-form-1" do
          refute has_checkbox with_options: 'Consent to survey'
        end
      end
    end
  end
end
