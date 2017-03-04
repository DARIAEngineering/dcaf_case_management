require 'test_helper'

class PledgeFulfillmentTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user, role: :cm
    @admin = create :user, role: :admin
    @data_volunteer = create :user, role: :data_volunteer
    @patient = create :patient, clinic_name: 'Nice Clinic',
                                appointment_date: 2.weeks.from_now
    @pregnancy = create :pregnancy, patient: @patient,
                                    pledge_sent: false, dcaf_soft_pledge: 500
    @fulfillment = create :fulfillment, patient: @patient
  end

  after do
    Capybara.use_default_driver
  end

  describe 'visiting the edit patient view as a CM' do
    before do
      log_in_as @user
      visit edit_patient_path @patient
    end

    after do
      sign_out
    end

    it 'should not show the pledge fulfillment link to a CM' do
      refute has_text? 'Pledge Fulfillment'
      refute has_link? 'Pledge Fulfillment'
    end
  end

  describe 'visiting the edit patient view as an admin' do
    before do
      log_in_as @admin
      visit edit_patient_path @patient
    end

    after do
      sign_out
    end

    it 'should not show the fulfillment link to an admin unless pledge sent' do
      refute has_text? 'Pledge Fulfillment'
      refute has_link? 'Pledge Fulfillment'
    end

    it 'should show a link to the pledge fulfillment tab after pledge sent' do
      find('#submit-pledge-button').click
      find('#pledge-next').click
      find('#pledge-next').click
      check 'I sent the pledge'
      find('#pledge-next').click
      wait_for_no_element 'Submit and send your pledge'
      wait_for_ajax
      visit authenticated_root_path
      visit edit_patient_path @patient
      wait_for_element 'Patient information'

      assert has_link? 'Pledge Fulfillment'
      click_link 'Pledge Fulfillment'
      assert has_text? 'Clinic: Nice Clinic'
      assert has_text? 'DCAF Pledge Amount: $500'
      assert has_text? 'Procedure date'
      assert has_text? 'Check #'
    end
  end

  describe 'visiting the edit patient view as a data volunteer' do
    before do
      log_in_as @data_volunteer
      visit edit_patient_path @patient
    end

    it 'should not show the fulfillment link to a data_volunteer unless pledge sent' do
      refute has_text? 'Pledge Fulfillment'
      refute has_link? 'Pledge Fulfillment'
    end

    it 'should show a link to the pledge fulfillment tab after pledge sent' do
      find('#submit-pledge-button').click
      find('#pledge-next').click
      find('#pledge-next').click
      check 'I sent the pledge'
      find('#pledge-next').click
      wait_for_no_element 'Submit and send your pledge'
      wait_for_ajax

      visit authenticated_root_path
      visit edit_patient_path @patient

      assert has_link? 'Pledge Fulfillment'
      click_link 'Pledge Fulfillment'
      assert has_text? 'Procedure date'
      assert has_text? 'Check #'
    end
  end
end
