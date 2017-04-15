require 'test_helper'

class DataEntryTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    @clinic = create :clinic
    log_in_as @user
    visit data_entry_path
    has_text? 'PATIENT ENTRY' # wait until load
  end

  after { Capybara.use_default_driver }

  describe 'entering a new patient' do
    before do
      # fill out the form
      select 'DC', from: 'patient_line'
      fill_in 'Initial call date', with: 2.days.ago.strftime('%m/%d/%y')
      fill_in 'Name', with: 'Susie Everyteen'
      fill_in 'Primary phone', with: '111-222-3344'
      fill_in 'Other contact name', with: 'Billy Everyteen'
      fill_in 'Other phone', with: '111-555-9999'
      fill_in 'Relationship to other contact', with: 'Friend'
      select '1 week', from: 'patient_pregnancy_last_menstrual_period_weeks'
      select '2 days', from: 'patient_pregnancy_last_menstrual_period_days'
      fill_in 'City', with: 'Washington'
      fill_in 'State', with: 'DC'
      fill_in 'Dcaf soft pledge', with: '100'
      fill_in 'Age', with: '30'
      select 'Other', from: 'patient_race_ethnicity'
      select @clinic.name, from: 'patient_clinic_id'
      fill_in 'Appointment date', with: 1.day.ago.strftime('%Y-%m-%d')
      select 'DC Medicaid', from: 'patient_insurance'
      select '1', from: 'patient_household_size_adults'
      select '2', from: 'patient_household_size_children'
      select 'Student', from: 'patient_employment_status'
      select 'Under $9,999 ($192/wk - $833/mo)', from: 'patient_income'
      select 'Clinic', from: 'patient_referred_by'
      fill_in 'Full cost / abortion cost', with: '200'
      fill_in 'Patient contribution', with: '150'
      fill_in 'National Abortion Federation pledge', with: '50'
      check 'Pledge sent'
      check 'Fetal diagnosis'
      check 'Homelessness'
      click_button 'Create Patient'
      has_text? 'Patient information' # wait for redirect
      #  problem here
    end

    it 'should log a new patient ready for further editing: dashboard' do
      within :css, '#patient_dashboard' do
        lmp_weeks = find('#patient_pregnancy_last_menstrual_period_weeks')
        lmp_days = find('#patient_pregnancy_last_menstrual_period_days')
        assert has_field?('First and last name', with: 'Susie Everyteen')
        assert_equal '1', lmp_weeks.value
        assert_equal '2', lmp_days.value
        assert has_field?('Appointment date',
                          with: 1.day.ago.strftime('%Y-%m-%d'))
        assert has_field? 'Phone number', with: '111-222-3344'
      end
    end

    it 'should log a new patient ready for further editing: information' do
      within :css, '#patient_information' do
        assert has_field? 'Other contact name', with: 'Billy Everyteen'
        assert has_field? 'Other phone', with: '111-555-9999'
        assert has_field? 'Relationship to other contact', with: 'Friend'
        assert has_field? 'Age', with: '30'
        assert_equal 'Other', find('#patient_race_ethnicity').value
        assert has_field? 'City', with: 'Washington'
        assert has_field? 'State', with: 'DC'

        assert_equal 'Student', find('#patient_employment_status').value
        assert_equal 'Under $9,999',
                     find('#patient_income').value
        assert_equal '1', find('#patient_household_size_adults').value
        assert_equal '2', find('#patient_household_size_children').value
        assert_equal 'DC Medicaid', find('#patient_insurance').value
        assert_equal 'Clinic', find('#patient_referred_by').value
        assert has_checked_field? 'Fetal diagnosis'
        assert has_checked_field? 'Homelessness'
      end
    end

    it 'should log a new patient ready for further editing: abortion' do
      click_link 'Abortion Information'
      within :css, '#abortion_information' do
        assert_equal @clinic.id.to_s, find('#patient_clinic_id').value
        assert has_field? 'Abortion cost', with: '200'
        assert has_field? 'Patient contribution', with: '150'
        assert has_field? 'National Abortion Federation pledge', with: '50'
        assert has_field? 'DCAF pledge', with: '100'
      end
    end
  end

  describe 'entering bad data' do
    describe 'bad phone' do
      before do
        create :patient, primary_phone: '111-111-1111'

        select 'DC', from: 'patient_line'
        fill_in 'Initial call date', with: 2.days.ago.strftime('%m/%d/%y')
        fill_in 'Name', with: 'Susie Everyteen'
        fill_in 'Primary phone', with: '111-111-1111'
        click_button 'Create Patient'
      end

      it 'should return an error on a duplicate phone' do
        assert has_text? 'Primary phone is already taken'
        assert_equal current_path, data_entry_path
      end
    end

    describe 'pledge with insufficient other info' do
      before do
        select 'DC', from: 'patient_line'
        fill_in 'Initial call date', with: 2.days.ago.strftime('%m/%d/%y')
        fill_in 'Name', with: 'Susie Everyteen'
        fill_in 'Primary phone', with: '111-222-3344'
        check 'Pledge sent'
        click_button 'Create Patient'
      end

      it 'should return an error on insufficient pledge sent data' do
        assert has_text? 'Pregnancy is invalid'
        assert_equal current_path, data_entry_path
      end
    end
  end
end
