require 'application_system_test_case'

class EventLogInteractionTest < ApplicationSystemTestCase
  before do
    @user = create :user, role: 'admin', name: 'Billy'
    @user2 = create :user, role: 'cm', name: 'Susie'

    @patient = create :patient, name: 'tester',
                                primary_phone: '1231231234',
                                city: 'Washington'
    log_in_as @user
    visit edit_patient_path @patient
  end

  describe 'logging phone calls' do
    it 'should log a phone call into the activity log' do
      wait_for_element 'Call Log'
      click_on 'Call Log'
      click_on 'Record new call'
      wait_for_element 'I left a voicemail for the patient'
      click_on 'I left a voicemail for the patient'
      wait_for_ajax
      wait_for_no_element 'I left a voicemail for the patient'
      visit authenticated_root_path
      sign_out

      wait_for_element 'Sign in with password'
      log_in_as @user2
      wait_for_css '#activity_log_content'
      wait_for_css '#event-item'
      wait_for_ajax
      wait_for_no_css '.sk-spinner'

      within :css, '#activity_log_content' do
        assert has_content? "#{@user.name} left a voicemail for " \
                            "#{@patient.name}"
      end

      assert_difference '@user2.call_list_entries.count', 1 do
        click_on '(Add to call list)'
        wait_for_ajax
        @user2.reload
      end
    end

    describe 'sending pledges' do
      it 'should log sent pledges' do
        @patient.update clinic: create(:clinic),
                        fund_pledge: 100,
                        appointment_date: 3.days.from_now
        visit edit_patient_path @patient

        find('#submit-pledge-button').click
        wait_for_element 'Patient name'
        assert has_text? 'Confirm the following information is correct'
        find('#pledge-next').click
        wait_for_ajax

        wait_for_no_element 'Confirm the following information is correct'
        assert has_text? 'Generate your pledge form'
        find('#pledge-next').click
        wait_for_no_element 'Review this preview of your pledge'

        assert has_text? 'Awesome, you generated a DCAF'
        check 'I sent the pledge'
        wait_for_ajax
        find('#pledge-next').click
        wait_for_no_element 'Awesome, you generated a DCAF'

        visit authenticated_root_path
        within :css, '#activity_log_content' do
          assert has_content? "#{@user.name} sent a pledge for " \
                              "#{@patient.name}"
        end
      end
    end
  end
end
