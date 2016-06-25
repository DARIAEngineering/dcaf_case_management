require 'test_helper'

class UpdatePatientInfoTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @patient = create :patient
    @pregnancy = create :pregnancy, patient: @patient
    log_in_as @user
    visit edit_pregnancy_path @pregnancy
    has_text? 'First and last name' # wait until page loads
  end

  describe 'changing patient dashboard information' do
    before do
      fill_in 'First and last name', with: 'Susie Everyteen 2'
      find('#pregnancy_last_menstrual_period_weeks').select '5 weeks'
      find('#pregnancy_last_menstrual_period_days').select '2 days'
      # fill_in 'Appointment date', with: '12/20/2016' PUNT
      fill_in 'Phone number', with: '123-666-8888'
      click_button 'TEMP: SAVE INFORMATION'
      visit authenticated_root_path
      visit edit_pregnancy_path @pregnancy
    end

    it 'should alter the information' do
      within :css, '#patient_dashboard' do
        assert has_field?('First and last name', with: 'Susie Everyteen 2')
        assert_equal find('#pregnancy_last_menstrual_period_weeks').value, '5'
        assert_equal find('#pregnancy_last_menstrual_period_days').value, '2'
        # assert has_field?('Appointment date', with: '12/20/2016') PUNT
        assert has_field? 'Phone number', with: '123-666-8888'
      end
    end
  end

  describe 'changing abortion information' do
    before do
      fill_in 'Clinic name', with: 'Stub Clinic'
      # TODO: finish this after implementing clinic logic
      fill_in 'Abortion Cost:', with: '300'
      # TODO: and this, once we have funding sources
      click_button 'TEMP: SAVE INFORMATION'
      visit authenticated_root_path
      visit edit_pregnancy_path @pregnancy
    end

    it 'should alter the information' do
      within :css, '#abortion_information' do
        assert has_field?('Clinic name', with: 'Stub Clinic')
        # TK after clinic logic
        assert has_field? 'Abortion Cost:', with: '300'
        # TK after funding sources
      end
    end
  end

  describe 'changing patient information' do
    before do
      fill_in 'Secondary person', with: 'Susie Everyteen Sr'
      fill_in 'Secondary phone', with: '123-666-7777'
      fill_in 'Age', with: '24'
      find('#pregnancy_race_ethnicity').select 'White/Caucasian'
      fill_in 'City', with: 'Washington'
      fill_in 'State', with: 'DC'
      fill_in 'ZIP', with: '90210'

      find('#pregnancy_employment_status').select 'Part-time'
      find('#pregnancy_income').select '$30,000-34,999 ($577-672/week)'
      find('#pregnancy_people_in_household').select '1'
      find('#pregnancy_patient_insurance').select 'Other state medicaid'
      find('#pregnancy_referred_by').select 'Other abortion fund'
      find('#pregnancy_special_circumstances').select 'Other'
      fill_in 'Referred by', with: 'Friend'

      click_button 'TEMP: SAVE INFORMATION'
      visit authenticated_root_path
      visit edit_pregnancy_path @pregnancy
    end

    it 'should alter the information' do
      within :css, '#patient_information' do
        assert has_field? 'Secondary person', with: 'Susie Everyteen Sr'
        assert has_field? 'Secondary phone', with: '123-666-7777'
        assert has_field? 'Age', with: '24'
        assert_equal find('#pregnancy_race_ethnicity').value, 'White/Caucasian'
        assert has_field? 'City', with: 'Washington'
        assert has_field? 'State', with: 'DC'
        assert has_field? 'ZIP', with: '90210'

        assert_equal find('#pregnancy_employment_status').value, 'Part-time'
        assert_equal find('#pregnancy_income').value '$30,000-34,999 ($577-672/week)'
        assert_equal find('#pregnancy_people_in_household').value '1'
        assert_equal find('#pregnancy_patient_insurance').value 'Other state medicaid'
        assert_equal find('#pregnancy_referred_by').value 'Other abortion fund'
        assert_equal find('#pregnancy_special_circumstances').value 'Other'
        # TK Special circumstances
      end
    end
  end
end
