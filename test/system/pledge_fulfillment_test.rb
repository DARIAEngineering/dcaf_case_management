require 'application_system_test_case'

# Confirm behavior around pledge fulfillment
class PledgeFulfillmentTest < ApplicationSystemTestCase
  before do
    @user = create :user, role: :cm
    @admin = create :user, role: :admin
    @clinic = create :clinic
    @data_volunteer = create :user, role: :data_volunteer

    @pledged_pt = create :patient, clinic: @clinic,
                                   appointment_date: 2.weeks.from_now,
                                   fund_pledge: 500,
                                   pledge_sent: true
    @nonpledged_pt = create :patient, clinic: @clinic,
                                      appointment_date: 2.weeks.from_now,
                                      fund_pledge: 500
    @fulfillment = create :fulfillment, patient: @pledged_pt
  end

  describe 'visiting the edit patient view as a CM' do
    before do
      log_in_as @user
      visit edit_patient_path @pledged_pt
    end

    it 'should not show the pledge fulfillment link to a CM' do
      refute has_text? 'Pledge Fulfillment'
      refute has_link? 'Pledge Fulfillment'
    end
  end

  describe 'visiting the edit patient view as an admin' do
    before do
      log_in_as @admin
    end

    it 'should not show the fulfillment link to an admin unless pledge sent' do
      visit edit_patient_path @nonpledged_pt
      refute has_text? 'Pledge Fulfillment'
      refute has_link? 'Pledge Fulfillment'
    end

    it 'should show a link to the pledge fulfillment tab after pledge sent' do
      visit edit_patient_path @pledged_pt
      wait_for_element 'Patient information'

      assert has_link? 'Pledge Fulfillment'
      click_link 'Pledge Fulfillment'
      assert has_text? "Clinic: #{@clinic.name}"
      assert has_text? 'DCAF Pledge Amount: $500'
      assert has_text? 'Procedure date'
      assert has_text? 'Check #'
    end
  end

  describe 'visiting the edit patient view as a data volunteer' do
    before do
      log_in_as @data_volunteer
    end

    it 'should not show fulfillment to a data_volunteer unless pledge sent' do
      visit edit_patient_path @nonpledged_pt
      refute has_text? 'Pledge Fulfillment'
      refute has_link? 'Pledge Fulfillment'
    end

    it 'should show a link to the pledge fulfillment tab after pledge sent' do
      visit edit_patient_path @pledged_pt
      wait_for_element 'Patient information'

      assert has_link? 'Pledge Fulfillment'
      click_link 'Pledge Fulfillment'
      assert has_text? 'Procedure date'
      assert has_text? 'Check #'
    end
  end

  describe 'pledge fulfilled autochecking on change' do
    before do
      log_in_as @admin
      visit edit_patient_path @pledged_pt
      wait_for_element 'Patient information'
      assert has_link? 'Pledge Fulfillment'
      click_link 'Pledge Fulfillment'
    end

    it 'should autocheck on field change' do
      fill_in 'patient_fulfillment_procedure_cost', with: '10'
      # Trigger a field change / save
      fill_in 'patient_fulfillment_check_number', with: ''
      assert has_checked_field? 'Pledge fulfilled'
    end

    it 'should uncheck when all fields are empty' do
      fill_in 'patient_fulfillment_procedure_cost', with: '10'
      fill_in 'patient_fulfillment_check_number', with: '10340'
      fill_in 'patient_fulfillment_procedure_date', with: '2017/05/25'
      select '1 week', from: 'patient_fulfillment_gestation_at_procedure'
      assert has_checked_field? 'Pledge fulfilled'

      fill_in 'patient_fulfillment_procedure_cost', with: ''
      fill_in 'patient_fulfillment_check_number', with: ''
      assert has_checked_field? 'Pledge fulfilled'

      fill_in 'patient_fulfillment_procedure_date', with: 'mm/dd/yyyy'
      select '', from: 'patient_fulfillment_gestation_at_procedure'
      assert has_no_checked_field? 'Pledge fulfilled'
    end
  end
end
