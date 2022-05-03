require 'application_system_test_case'

class AccountantWorkflowTest < ApplicationSystemTestCase
  extend Minitest::OptionalRetry

  before do
    @user = create :user, role: :admin
    @clinic = create :clinic, name: 'a real clinic'
    @line = create :line
    @another_clinic = create :clinic, name: 'alternative clinic'

    @nonpledged_patient = create :patient, name: 'Eileene Zarha',
                                           initial_call_date: 5.weeks.ago,
                                           line: @line

    @pledged_patient = create :patient, name: 'Olga Zarha',
                                        fund_pledge: 100,
                                        clinic: @clinic,
                                        pledge_sent: true,
                                        appointment_date: 2.weeks.ago,
                                        initial_call_date: 5.weeks.ago,
                                        line: @line

    @fulfilled_patient = create :patient, name: 'Thorny Zarha',
                                          fund_pledge: 200,
                                          clinic: @clinic,
                                          pledge_sent: true,
                                          appointment_date: 2.weeks.ago,
                                          initial_call_date: 5.weeks.ago,
                                          line: @line
    @fulfilled_patient.fulfillment.update fulfilled: true,
                                          procedure_date: 1.week.ago,
                                          gestation_at_procedure: '3 weeks',
                                          fund_payout: 350,
                                          check_number: 'A103',
                                          date_of_check: 1.day.ago

    @other_clinic_patient = create :patient, name: 'Marina Zarha',
                                             clinic: @another_clinic,
                                             pledge_sent: true,
                                             fund_pledge: 123,
                                             appointment_date: 2.weeks.ago,
                                             initial_call_date: 5.weeks.ago,
                                             line: @line


    log_in_as @user, @line
    visit accountants_path
  end

  describe 'admin wall' do
    [:cm].each do |role|
      it "should ban nonadmins from accessing accounting page - #{role}" do
        @nonadmin_user = create :user, role: role
        log_out
        log_in_as @nonadmin_user

        visit accountants_path
        refute has_text? 'Accountant Dashboard'
      end
    end
  end

  describe 'viewing pledged patients' do
    it 'should show only pledged patients on page load' do
      assert has_content? @fulfilled_patient.name
      assert has_content? @pledged_patient.name
      refute has_content? @nonpledged_patient.name
    end

    it 'should properly display counts' do
      assert has_content? 'Displaying all 3 patients'
    end

    it 'should properly display large numbers of patients' do
      30.times do |i|
        Patient.create! name: "Patient #{i}",
                        appointment_date: 3.days.from_now,
                        clinic: @clinic,
                        fund_pledge: 100,
                        initial_call_date: 3.days.ago,
                        line: @line,
                        naf_pledge: 200,
                        patient_contribution: 100,
                        pledge_sent: true,
                        primary_phone: "999-888-#{1000 + i}",
                        procedure_cost: 400
      end

      # gotta reload!
      visit accountants_path

      assert has_content? 'Displaying patients 1 - 25 of 33 in total'

      # the table should have 25 rows
      assert has_selector?('#accountants-table-content tr', count: 25)
    end
  end

  describe 'searching for pledged patients' do
    it 'should filter to searched for patients' do
      fill_in 'Search', with: @fulfilled_patient.name
      click_button 'Search'
      wait_for_ajax

      assert has_content? @fulfilled_patient.name
      refute has_content? @pledged_patient.name
      refute has_content? @other_clinic_patient.name
      refute has_content? @nonpledged_patient.name

      assert has_content? 'Displaying 1 patient'
    end

    it 'should display everyone on a search for an empty string' do
      fill_in 'Search', with: 'whatever'
      click_button 'Search'
      wait_for_ajax

      fill_in 'Search', with: ''
      click_button 'Search'
      wait_for_ajax

      assert has_content? @fulfilled_patient.name
      assert has_content? @pledged_patient.name
      assert has_content? @other_clinic_patient.name
      refute has_content? @nonpledged_patient.name

      assert has_content? 'Displaying all 3 patients'
    end

    it 'should search by clinic' do
      fill_in 'Search', with: ''
      select 'alternative clinic', from: 'clinic_id'
      click_button 'Search'
      wait_for_ajax

      assert has_content? @other_clinic_patient.name
      refute has_content? @fulfilled_patient.name
      refute has_content? @pledged_patient.name
      refute has_content? @nonpledged_patient.name

      assert has_content? 'Displaying 1 patient'
    end

    it 'should display everyone on search for all clinics' do
      fill_in 'Search', with: ''
      select '[All Clinics]', from: 'clinic_id'
      click_button 'Search'
      wait_for_ajax

      assert has_content? @fulfilled_patient.name
      assert has_content? @pledged_patient.name
      assert has_content? @other_clinic_patient.name
      refute has_content? @nonpledged_patient.name

      assert has_content? 'Displaying all 3 patients'
    end
  end

  describe 'updating pledged patient information' do
    it 'should let you update the patient information' do
      find("#edit-#{@pledged_patient.id}").click
      sleep(1)
      wait_for_ajax

      within :css, '.modal-content' do
        # Modal should show the patient's edit form
        assert has_content? 'Pledge Fulfillment'
        assert has_content? "Clinic: #{@clinic.name}"

        # And should let you update it
        fill_in 'CATF payout', with: '999'
        fill_in 'Check #', with: 'BB8'
        find('h2').click # Click the header to get the field to save
        wait_for_ajax
      end
      find('body').click
      send_keys :escape
      sleep 1

      # Now, should be updated!
      within :css, "#row-#{@pledged_patient.id}" do
        assert has_content? '$999'
        assert has_content? 'BB8'
      end
    end
  end
end
