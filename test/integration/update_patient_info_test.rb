require 'test_helper'

class UpdatePatientInfoTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    @patient = create :patient
    @pregnancy = create :pregnancy, patient: @patient
    @ext_pledge = create :external_pledge,
                         patient: @patient,
                         source: 'Baltimore Abortion Fund'
    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name' # wait until page loads
  end

  after do
    Capybara.use_default_driver
  end

  describe 'changing patient dashboard information' do
    before do
      @date = 5.days.from_now.strftime('%Y-%m-%d')
      fill_in 'First and last name', with: 'Susie Everyteen 2'
      select '5 weeks', from: 'patient_pregnancy_last_menstrual_period_weeks'
      select '2 days', from: 'patient_pregnancy_last_menstrual_period_days'
      fill_in 'Appointment date', with: @date
      fill_in 'Phone number', with: '123-666-8888'
      fill_in 'First and last name', with: 'Susie Everyteen 2'
      wait_for_ajax

      visit authenticated_root_path
      visit edit_patient_path @patient
    end

    it 'should alter the information' do
      within :css, '#patient_dashboard' do
        lmp_weeks = find('#patient_pregnancy_last_menstrual_period_weeks')
        lmp_days = find('#patient_pregnancy_last_menstrual_period_days')
        assert has_field?('First and last name', with: 'Susie Everyteen 2')
        assert_equal '5', lmp_weeks.value
        assert_equal '2', lmp_days.value
        assert has_field?('Appointment date', with: @date)
        assert has_field? 'Phone number', with: '123-666-8888'
      end
    end
  end

  describe 'changing abortion information' do
    before do
      click_link 'Abortion Information'
      select 'Sample Clinic 1', from: 'patient_clinic_name'
      check 'Resolved without assistance from DCAF'

      fill_in 'Abortion cost', with: '300'
      fill_in 'Patient contribution', with: '200'
      fill_in 'National Abortion Federation pledge', with: '50'
      fill_in 'DCAF pledge', with: '25'
      fill_in 'Baltimore Abortion Fund pledge', with: '25', match: :prefer_exact

      click_away_from_field
      visit authenticated_root_path
      visit edit_patient_path @patient
      click_link 'Abortion Information'
      page.driver.resize(2000, 2000)
    end

    it 'should alter the information' do
      within :css, '#abortion_information' do
        assert_equal 'Sample Clinic 1', find('#patient_clinic_name').value
        assert_equal '1', find('#patient_pregnancy_resolved_without_dcaf').value
        # TODO: review after getting clinic logic in place

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
      fill_in 'Age', with: '24'
      select 'White/Caucasian', from: 'patient_race_ethnicity'
      fill_in 'City', with: 'Washington'
      fill_in 'State', with: 'DC'
      fill_in 'ZIP', with: '90210'
      select 'Voicemail OK', from: 'patient_voicemail_preference'
      check 'Spanish Only'

      select 'Part-time', from: 'patient_employment_status'
      select '$30,000-34,999 ($577-672/week)', from: 'patient_income'
      select '1', from: 'patient_household_size_adults'
      select '3', from: 'patient_household_size_children'
      select 'Other state Medicaid', from: 'patient_insurance'
      select 'Other abortion fund', from: 'patient_referred_by'
      check 'Homelessness'
      check 'Prison'

      click_away_from_field
      visit authenticated_root_path
      visit edit_patient_path @patient
    end

    # problematic test
    it 'should alter the information' do
      click_link 'Patient Information'
      within :css, '#patient_information' do
        assert has_field? 'Other contact name', with: 'Susie Everyteen Sr'
        assert has_field? 'Other phone', with: '123-666-7777'
        assert has_field? 'Relationship to other contact', with: 'Friend'
        assert has_field? 'Age', with: '24'
        assert_equal 'White/Caucasian', find('#patient_race_ethnicity').value
        assert has_field? 'City', with: 'Washington'
        assert has_field? 'State', with: 'DC'
        assert has_field? 'ZIP', with: '90210'
        assert_equal 'yes', find('#patient_voicemail_preference').value
        assert has_checked_field? 'Spanish Only'

        assert_equal 'Part-time', find('#patient_employment_status').value
        assert_equal '$30,000-34,999 ($577-672/week)',
                     find('#patient_income').value
        assert_equal '1', find('#patient_household_size_adults').value
        assert_equal '3', find('#patient_household_size_children').value
        assert_equal 'Other state Medicaid', find('#patient_insurance').value
        assert_equal 'Other abortion fund', find('#patient_referred_by').value
        assert_equal 'yes', find('#patient_voicemail_preference').value
        assert has_checked_field? 'Spanish Only'
        assert has_checked_field? 'Homelessness'
        assert has_checked_field? 'Prison'
      end
    end
  end

  private

  def click_away_from_field
    fill_in 'First and last name', with: nil
    wait_for_ajax
  end
end
