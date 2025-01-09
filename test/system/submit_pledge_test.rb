require 'application_system_test_case'

# Tests around plege submission behavior
class SubmitPledgeTest < ApplicationSystemTestCase
  before do
    @config = create :pledge_config, fund: ActsAsTenant.current_tenant
    @user = create :user, role: :data_volunteer
    @clinic = create :clinic, fax: "202-867-5309"
    @patient = create :patient, clinic: @clinic,
                                appointment_date: Time.zone.now + 14,
                                fund_pledge: 500,
                                shared_flag: true

    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name'
  end

  # this is a test for a persistent turbolinks bug
  # Mar 2023: we no longer use turbolinks, but leaving test in to be safe.
  it 'should load properly without other page touches' do
    visit dashboard_path
    click_link @patient.name
    find('#submit-pledge-button').click
    wait_for_ajax

    assert has_text? 'Confirm the following information is correct'
  end

  describe 'submitting a pledge' do
    it 'should let you mark a pledge submitted' do
      find('#submit-pledge-button').click
      wait_for_element 'Patient name'
      assert has_text? 'Confirm the following information is correct'
      find('#pledge-next').click
      wait_for_ajax

      wait_for_no_element 'Confirm the following information is correct'
      assert has_text? 'Generate your pledge form'
      find('#pledge-next').click
      wait_for_no_element 'Review this preview of your pledge'

      assert has_text? 'Awesome, you generated a CATF'
      # default - no email; show fax
      assert has_text? "202-867-5309"
      assert has_text? "Fax service:"
      check 'I sent the pledge'
      wait_for_ajax
      find('#pledge-next').click
      wait_for_no_element 'Awesome, you generated a CATF'

      wait_for_ajax
      wait_for_element 'Patient information'

      assert_equal find('#patient_status_display').value, Patient::STATUSES[:pledge_sent][:key]
      assert has_link? 'Fulfillment'
      assert has_link? 'Cancel pledge'
    end

    it 'should show clinic email instead of fax' do
      @clinic.email_for_pledges = "pledges@catfund.biz"
      @clinic.save!

      find('#submit-pledge-button').click
      wait_for_element 'Patient name'
      assert has_text? 'Confirm the following information is correct'
      find('#pledge-next').click
      wait_for_ajax

      wait_for_no_element 'Confirm the following information is correct'
      assert has_text? 'Generate your pledge form'
      find('#pledge-next').click
      wait_for_no_element 'Review this preview of your pledge'

      assert has_text? 'Awesome, you generated a CATF'
      # now we should see the email
      
      assert has_text? "pledges@catfund.biz"
      refute has_text? "Fax service"
    end

    it 'should render after opening call modal' do
      click_link 'Call Log'
      wait_for_element 'Record new call'
      wait_for_element "Call #{@patient.name} now:"

      find('#submit-pledge-button').click
      wait_for_element 'Patient name'
      assert has_text? 'Confirm the following information is correct'
      find('#pledge-next').click
      wait_for_ajax

      wait_for_no_element 'Confirm the following information is correct'
      assert has_text? 'Generate your pledge form'
    end
  end

  describe 'cancelling a pledge' do
    before do
      @patient.update pledge_sent: true,
                      appointment_date: 2.weeks.from_now,
                      fund_pledge: 500

      visit edit_patient_path @patient
      wait_for_element 'Patient information'
    end

    it 'should not cancel if not rescinded' do
      assert has_link? 'Cancel pledge'
      find('#cancel-pledge-button').click

      assert has_text? 'Are you sure you want to cancel this pledge?'
      click_button 'No'

      wait_for_ajax
      wait_for_element 'Patient information'

      assert has_link? 'Cancel pledge'
    end

    it 'should cancel if user rescinds' do
      assert has_link? 'Cancel pledge'
      find('#cancel-pledge-button').click

      wait_for_element 'Are you sure you want to cancel this pledge?'
      click_button 'Yes'
      wait_for_ajax

      assert has_link? 'Submit pledge'
      assert_equal find('#patient_status_display').value, Patient::STATUSES[:no_contact][:key]
      refute has_link? 'Fulfillment'
    end
  end

  describe 'displaying pledge generator input' do
    it 'should display when config set' do
      find('#submit-pledge-button').click
      wait_for_element 'Patient name'
      assert has_text? 'Confirm the following information is correct'
      find('#pledge-next').click
      wait_for_ajax
      assert has_content? 'Note that this does NOT send your pledge to the clinic! Please click to the next page after generating your form to record that you have sent the pledge to the clinic.'

      @config.update remote_pledge: true, remote_pledge_extras: {cat_town: true}
      ActsAsTenant.current_tenant.reload
      visit edit_patient_path @patient
      find('#submit-pledge-button').click
      wait_for_element 'Patient name'
      assert has_text? 'Confirm the following information is correct'
      find('#pledge-next').click
      wait_for_ajax
      assert has_text? 'Cat town'
      assert has_text? 'Enter your name in this box to sign your pledge'

      @config.destroy
      ActsAsTenant.current_tenant.reload
      visit edit_patient_path @patient
      find('#submit-pledge-button').click
      wait_for_element 'Patient name'
      assert has_text? 'Confirm the following information is correct'
      find('#pledge-next').click
      wait_for_ajax
      assert has_content? 'Please generate your pledge form and click next.'
    end
  end
end
