require 'test_helper'

class UpdatePatientInfoTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    @patient = create :patient
    @pregnancy = create :pregnancy, patient: @patient
    log_in_as @user
    visit edit_pregnancy_path @pregnancy
    has_text? 'First and last name' # wait until page loads
  end

  after do
    Capybara.use_default_driver
  end

  describe 'changing patient dashboard information' do
    before do
      fill_in 'First and last name', with: 'Susie Everyteen 2'
      find('#pregnancy_last_menstrual_period_weeks').select '5 weeks'
      find('#pregnancy_last_menstrual_period_days').select '2 days'
      # fill_in 'Appointment date', with: '12/20/2016' PUNT
      fill_in 'Phone number', with: '123-666-8888'

      click_away_from_field
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
      click_link 'Abortion Information'
      fill_in 'Clinic name', with: 'Stub Clinic'
      # TODO: finish this after implementing clinic logic
      fill_in 'Abortion Cost:', with: '300'
      # TODO: and this, once we have funding sources
      click_away_from_field
      visit authenticated_root_path
      visit edit_pregnancy_path @pregnancy
      click_link 'Abortion Information'
    end

    # problematic test
    # it 'should alter the information' do
    #   within :css, '#abortion_information' do
    #     assert has_field?('Clinic name', with: 'Stub Clinic')
    #     # TK after clinic logic
    #     assert has_field? 'Abortion Cost:', with: '300'
    #     # TK after funding sources
    #   end
    # end
  end

  describe 'changing patient information' do
    before do
      click_link 'Patient Information'
      fill_in 'Secondary person', with: 'Susie Everyteen Sr'
      fill_in 'Secondary phone', with: '123-666-7777'
      fill_in 'Age', with: '24'
      find('#pregnancy_race_ethnicity').select 'White/Caucasian'
      fill_in 'City', with: 'Washington'
      fill_in 'State', with: 'DC'
      fill_in 'ZIP', with: '90210'

      find('#pregnancy_employment_status').select 'Part-time'
      find('#pregnancy_income').select '$30,000-34,999 ($577-672/week)'
      find('#pregnancy_household_size').select '1'
      find('#pregnancy_insurance').select 'Other state Medicaid'
      find('#pregnancy_referred_by').select 'Other abortion fund'
      fill_in 'Special circumstances', with: 'Stuff'

      click_away_from_field
      visit authenticated_root_path
      visit edit_pregnancy_path @pregnancy
    end

    it 'should alter the information' do
      click_link 'Patient Information'
      within :css, '#patient_information' do
        assert has_field? 'Secondary person', with: 'Susie Everyteen Sr'
        assert has_field? 'Secondary phone', with: '123-666-7777'
        assert has_field? 'Age', with: '24'
        assert_equal 'White/Caucasian', find('#pregnancy_race_ethnicity').value
        assert has_field? 'City', with: 'Washington'
        assert has_field? 'State', with: 'DC'
        assert has_field? 'ZIP', with: '90210'

        assert_equal 'Part-time', find('#pregnancy_employment_status').value
        assert_equal '$30,000-34,999 ($577-672/week)', find('#pregnancy_income').value
        assert_equal '1', find('#pregnancy_household_size').value
        assert_equal 'Other state Medicaid', find('#pregnancy_insurance').value
        assert_equal 'Other abortion fund', find('#pregnancy_referred_by').value
        assert_equal 'Stuff', find('#pregnancy_special_circumstances').value
      end
    end
  end

  private

  def click_away_from_field
    fill_in 'First and last name', with: nil
  end
end
