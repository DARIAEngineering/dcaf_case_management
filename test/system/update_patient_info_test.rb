require 'application_system_test_case'

class UpdatePatientInfoTest < ApplicationSystemTestCase
  before do
    @user = create :user
    @admin = create :user, role: :admin
    @clinic = create :clinic
    @patient = create :patient, line: :DC
    @ext_pledge = create :external_pledge,
                         patient: @patient,
                         source: 'Baltimore Abortion Fund'
    create_external_pledge_source_config
    create_insurance_config
    create_language_config

    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name' # wait until page loads
  end

  describe 'changing patient dashboard information' do
    before do
      @date = 5.days.from_now
      fill_in 'First and last name', with: 'Susie Everyteen 2'
      select '5 weeks', from: 'patient_last_menstrual_period_weeks'
      select '2 days', from: 'patient_last_menstrual_period_days'
      fill_in 'Appointment date', with: @date.strftime('%m/%d/%Y')
      fill_in 'Phone number', with: '123-666-8888'
      fill_in 'First and last name', with: 'Susie Everyteen 2'
      click_away_from_field
      reload_page_and_click_link 'Patient Information'
    end

    it 'should alter the dashboard information' do
      within :css, '#patient_dashboard' do
        lmp_weeks = find('#patient_last_menstrual_period_weeks')
        lmp_days = find('#patient_last_menstrual_period_days')
        assert has_field?('First and last name', with: 'Susie Everyteen 2')
        assert_equal '5', lmp_weeks.value
        assert_equal '2', lmp_days.value

        assert has_field? 'Appointment date', with: @date.strftime('%Y-%m-%d')
        assert has_field? 'Phone number', with: '123-666-8888'

        assert has_content? 'Currently: 5w 4d'
        assert has_content? 'Approx gestation at appt: 6 weeks, 2 days'
      end
    end
  end

  describe 'changing abortion information' do
    before do
      click_link 'Abortion Information'
      select @clinic.name, from: 'patient_clinic_id'
      check 'Resolved without assistance from DCAF'
      check 'Referred to clinic'

      fill_in 'Abortion cost', with: '300'
      fill_in 'Patient contribution', with: '200'
      fill_in 'National Abortion Federation pledge', with: '50'
      fill_in 'DCAF pledge', with: '25'
      fill_in 'Baltimore Abortion Fund pledge', with: '25', match: :prefer_exact
      fill_in 'Abortion cost', with: '300'
      click_away_from_field
      reload_page_and_click_link 'Abortion Information'
    end

    it 'should update balance on field change' do
      # updateBalance()
      find('#outstanding-balance').has_text?('$0')

      fill_in 'Abortion cost', :with => '20000'
      find('#outstanding-balance').has_text?('$19700')
      fill_in 'Patient contribution', with: '0'
      find('#outstanding-balance').has_text?('$19900')
      fill_in 'National Abortion Federation pledge', with: '0'
      find('#outstanding-balance').has_text?('$19950')
      fill_in 'Baltimore Abortion Fund pledge', with: '0', match: :prefer_exact
      find('#outstanding-balance').has_text?('$19975')
      fill_in 'DCAF pledge', with: '0'
      find('#outstanding-balance').has_text?('$20000')
    end

    it 'should alter the abortion information' do
      within :css, '#abortion_information' do
        assert_equal @clinic.id.to_s, find('#patient_clinic_id').value
        assert has_checked_field?('Resolved without assistance from DCAF')
        assert has_checked_field?('Referred to clinic')

        assert has_field? 'Abortion cost', with: '300'
        assert has_field? 'Patient contribution', with: '200'
        assert has_field? 'National Abortion Federation pledge', with: '50'
        assert has_field? 'DCAF pledge', with: '25'
        assert has_field? 'Baltimore Abortion Fund pledge', with: '25'
      end
    end
  end

  describe 'changing patient information' do
    before do
      click_link 'Patient Information'
      fill_in 'Other contact name', with: 'Susie Everyteen Sr'
      fill_in 'Other phone', with: '123-666-7777'
      fill_in 'Relationship to other contact', with: 'Friend'
      wait_for_ajax

      fill_in 'Age', with: '24'
      select 'White/Caucasian', from: 'patient_race_ethnicity'
      fill_in 'City', with: 'Washington'
      wait_for_ajax

      fill_in 'State', with: 'DC'
      fill_in 'County', with: 'Wash'
      select 'Voicemail OK', from: 'patient_voicemail_preference'
      wait_for_ajax

      select 'Spanish', from: 'patient_language'
      select 'Part-time', from: 'patient_employment_status'
      select '$30,000-34,999 ($577-672/wk - $2500-2916/mo)',
             from: 'patient_income'
      wait_for_ajax

      select '1', from: 'patient_household_size_adults'
      select '3', from: 'patient_household_size_children'
      select 'Other state Medicaid', from: 'patient_insurance'
      wait_for_ajax

      select 'Other abortion fund', from: 'patient_referred_by'
      check 'Homelessness'
      check 'Prison'
      click_away_from_field
      wait_for_ajax

      reload_page_and_click_link 'Patient Information'
    end

    it 'should alter the patient information information' do
      within :css, '#patient_information' do
        assert has_field? 'Other contact name', with: 'Susie Everyteen Sr'
        assert has_field? 'Other phone', with: '123-666-7777'
        assert has_field? 'Relationship to other contact', with: 'Friend'
        assert has_field? 'Age', with: '24'
        assert_equal 'White/Caucasian', find('#patient_race_ethnicity').value
        assert has_field? 'City', with: 'Washington'
        assert has_field? 'State', with: 'DC'
        assert has_field? 'County', with: 'Wash'
        assert_equal 'yes', find('#patient_voicemail_preference').value
        assert_equal 'Spanish', find('#patient_language').value

        assert_equal 'Part-time', find('#patient_employment_status').value
        assert_equal '$30,000-34,999',
                     find('#patient_income').value
        assert_equal '1', find('#patient_household_size_adults').value
        assert_equal '3', find('#patient_household_size_children').value
        assert_equal 'Other state Medicaid', find('#patient_insurance').value
        assert_equal 'Other abortion fund', find('#patient_referred_by').value
        assert_equal 'yes', find('#patient_voicemail_preference').value
        assert_equal 'Spanish', find('#patient_language').value
        assert has_checked_field? 'Homelessness'
        assert has_checked_field? 'Prison'
        assert has_no_css? '#patient_line'
      end
    end

    describe 'changing ADMIN patient information' do
      before do
        @admin = create :user, role: :admin
        log_out
        log_in_as @admin
        visit edit_patient_path @patient
        wait_for_element 'Patient Information'

        select 'MD', from: 'patient_line'
        click_away_from_field
        reload_page_and_click_link 'Patient Information'
      end

      it 'should alter the information' do
        within :css, '#patient_information' do
          assert_equal 'MD', find('#patient_line').value
        end
      end
    end
  end

  describe 'flash notifications' do
    it 'should flash success on field change' do
      click_link 'Patient Information'
      fill_in 'Age', with: '25'
      click_away_from_field
      assert has_text? 'Patient info successfully saved'
    end

    it 'should flash failure on a bad field change' do
      fill_in 'Phone number', with: '111-222-3333445'
      click_away_from_field
      assert has_text? 'Primary phone is the wrong length'
    end
  end

  describe 'changing fulfillment information' do
    before do
      @patient = create :patient, appointment_date: 2.days.from_now,
                                  clinic: @clinic,
                                  fund_pledge: 100,
                                  pledge_sent: true
      create :fulfillment, patient: @patient

      log_out && log_in_as(@admin)
      visit edit_patient_path @patient

      click_link 'Pledge Fulfillment'
      fill_in 'Procedure date', with: 2.days.from_now.strftime('%m/%d/%Y')
      wait_for_ajax

      select '12 weeks', from: 'Weeks along at procedure'
      fill_in 'Abortion care $', with: '100'
      wait_for_ajax

      fill_in 'Check #', with: '444-22'
      fill_in 'Date of check', with: 2.weeks.from_now.strftime('%m/%d/%Y')

      click_away_from_field
      wait_for_ajax
      reload_page_and_click_link 'Pledge Fulfillment'
    end

    # PROBLEMATIC TEST
    it 'should alter the information' do
      within :css, '#pledge_fulfillment' do
        assert has_checked_field? 'Pledge fulfilled'
        assert has_field? 'Procedure date',
                          with: 2.days.from_now.strftime('%Y-%m-%d')
        assert_equal '12',
                     find('#patient_fulfillment_gestation_at_procedure').value
        assert has_field? 'Abortion care $', with: 100
        assert has_field? 'Check #', with: '444-22'

        # There is something deeply, deeply weird about how capybara enters dates.
        # assert has_field? 'Date of check',
        #                   with: 2.weeks.from_now.strftime('%Y-%m-%d')
      end
    end
  end

  describe 'clicking around' do
    it 'should let you click back to abortion information' do
      click_link 'Notes'
      within(:css, '#sections') { refute has_text? 'Abortion information' }
      click_link 'Abortion Information'
      within(:css, '#sections') { assert has_text? 'Abortion information' }
    end
  end

  private

  def reload_page_and_click_link(link_text)
    click_away_from_field
    visit authenticated_root_path
    visit edit_patient_path @patient
    click_link link_text
  end
end
