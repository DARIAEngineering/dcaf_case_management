require 'test_helper'

class SubmitPledgeTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user, role: :data_volunteer
    @clinic = create :clinic
    @patient = create :patient, clinic: @clinic,
                                appointment_date: Time.zone.now + 14,
                                fund_pledge: 500,
                                urgent_flag: true
    log_in_as @user
    visit edit_patient_path @patient
    has_text? 'First and last name'
  end

  after { Capybara.use_default_driver }

  # this is a test for a persistent turbolinks bug
  it 'should load properly without other page touches' do
    visit dashboard_path
    click_link @patient.name
    find('#submit-pledge-button').click
    sleep 2
    assert has_text? 'Confirm the following information is correct'
  end

  describe 'submitting a pledge' do
    it 'should let you mark a pledge submitted' do
      find('#submit-pledge-button').click
      wait_for_element 'Patient name'
      assert has_text? 'Confirm the following information is correct'
      find('#pledge-next').click
      sleep 2 # out of ideas

      wait_for_no_element 'Confirm the following information is correct'
      assert has_text? 'Generate your pledge form'
      find('#pledge-next').click
      wait_for_no_element 'Review this preview of your pledge'

      assert has_text? 'Awesome, you generated a DCAF'
      check 'I sent the pledge'
      wait_for_ajax
      find('#pledge-next').click
      wait_for_no_element 'Awesome, you generated a DCAF'

      wait_for_ajax
      wait_for_element 'Patient information'

      assert has_text? Patient::STATUSES[:pledge_sent]
      assert has_link? 'Fulfillment'
      assert has_link? 'Cancel pledge'
    end

    it 'should render after opening call modal' do
      click_link 'Call Log'
      wait_for_element 'Record new call'
      wait_for_element "Call #{@patient.name} now:"

      find('#submit-pledge-button').click
      wait_for_element 'Patient name'
      assert has_text? 'Confirm the following information is correct'
      find('#pledge-next').click
      sleep 2 # out of ideas

      wait_for_no_element 'Confirm the following information is correct'
      assert has_text? 'Generate your pledge form'
    end
  end

  describe 'cancelling a pledge' do
    before do
      @patient.update pledge_sent: true,
                      appointment_date: 2.weeks.from_now,
                      fund_pledge: 500

      @fulfillment = create :fulfillment, patient: @patient
      visit edit_patient_path @patient
      wait_for_element 'Patient information'
    end

    it 'should render after opening call modal' do
      click_link 'Call Log'
      wait_for_element 'Record new call'
      wait_for_element "Call #{@patient.name} now:"

      find('#cancel-pledge-button').click
      wait_for_ajax

      wait_for_element 'If you wish to cancel a pledge (such as to change it and resend it), please proceed to the next page'
      assert has_text? 'Cancel pledge:'
      find('#pledge-next').click
      wait_for_ajax

      wait_for_no_element 'Cancel pledge:'
      assert has_text? 'To confirm you want to cancel this pledge, please uncheck the check box below.'
    end

    it 'should not cancel if not rescinded' do
      assert has_link? 'Cancel pledge'
      find('#cancel-pledge-button').click

      wait_for_element 'If you wish to cancel a pledge (such as to change it and resend it), please proceed to the next page'
      assert has_text? 'Cancel pledge:'
      find('#pledge-next').click
      sleep 1 # :(

      assert has_text? 'To confirm you want to cancel this pledge, please uncheck the check box below.'
      find('#pledge-next').click

      wait_for_ajax
      wait_for_element 'Patient information'

      assert has_link? 'Cancel pledge'
    end

    it 'should cancel if user rescinds' do
      assert has_link? 'Cancel pledge'
      find('#cancel-pledge-button').click

      wait_for_element 'If you wish to cancel a pledge (such as to change it and resend it), please proceed to the next page'
      assert has_text? 'Cancel pledge:'
      find('#pledge-next').click
      wait_for_ajax

      wait_for_no_element 'Cancel pledge:'
      assert has_text? 'To confirm you want to cancel this pledge, please uncheck the check box below.'
      find('#patient_pledge_sent').click
      wait_for_ajax
      sleep 1 # out of ideas
      wait_for_ajax

      find('#pledge-next').click
      assert has_link? 'Submit pledge'
      assert has_content? Patient::STATUSES[:no_contact]
      refute has_link? 'Fulfillment'
    end
  end
end
