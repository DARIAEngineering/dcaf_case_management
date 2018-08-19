require 'application_system_test_case'

class AccountantWorkflowTest < ApplicationSystemTestCase
  before do
    @user = create :user, role: :admin
    @clinic = create :clinic, name: 'a real clinic'

    @nonpledged_patient = create :patient, name: 'Eileene Zarha',
                                           initial_call_date: 5.weeks.ago

    @pledged_patient = create :patient, name: 'Olga Zarha',
                                        fund_pledge: 100,
                                        clinic: @clinic,
                                        pledge_sent: true,
                                        appointment_date: 2.weeks.ago,
                                        initial_call_date: 5.weeks.ago

    @fulfillment_data = attributes_for :fulfillment, fulfilled: true,
                                                     procedure_date: 1.week.ago,
                                                     gestation_at_procedure: '3 weeks',
                                                     procedure_cost: 350,
                                                     check_number: 'A103',
                                                     date_of_check: 1.day.ago
    @fulfilled_patient = create :patient, name: 'Thorny Zarha',
                                          fund_pledge: 200,
                                          clinic: @clinic,
                                          pledge_sent: true,
                                          appointment_date: 2.weeks.ago,
                                          fulfillment: @fulfillment_data,
                                          initial_call_date: 5.weeks.ago

    log_in_as @user
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
      # Or initials, as the case may be
      assert has_content? @fulfilled_patient.initials
      assert has_content? @pledged_patient.initials
      refute has_content? @nonpledged_patient.initials
    end
  end

  describe 'searching for pledged patients' do
    it 'should filter to searched for patients' do
      fill_in 'Search', with: @fulfilled_patient.name
      click_button 'Search'
      wait_for_ajax

      assert has_content? @fulfilled_patient.initials
      refute has_content? @pledged_patient.initials
      refute has_content? @nonpledged_patient.initials
    end

    it 'should display everyone on a search for an empty string' do
      fill_in 'Search', with: 'whatever'
      click_button 'Search'
      wait_for_ajax

      fill_in 'Search', with: ''
      click_button 'Search'
      wait_for_ajax

      assert has_content? @fulfilled_patient.initials
      assert has_content? @pledged_patient.initials
      refute has_content? @nonpledged_patient.initials
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
        fill_in 'Abortion care $', with: '999'
        fill_in 'Check #', with: 'BB8'
        find('h2').click # Click the header to get the field to save
        wait_for_ajax
      end
      find('body').click

      # Now, should be updated!
      within :css, "#row-#{@pledged_patient.id}" do
        assert has_content? '$999'
        assert has_content? 'BB8'
      end
    end
  end
end
