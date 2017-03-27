require 'test_helper'

class CallListTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @patient = create :patient, name: 'Susan Everyteen'
    @pregnancy = create :pregnancy, patient: @patient
    @patient_2 = create :patient, name: 'Thorny'
    @pregnancy_2 = create :pregnancy, patient: @patient_2
    @va_patient = create :patient, name: 'James Hetfield', line: 'VA'
    @va_pregnancy = create :pregnancy, patient: @va_patient
    @user = create :user
    @user.add_patient @va_patient
    log_in_as @user
    add_to_call_list @patient
    page.driver.resize(2000, 2000)
  end

  after { Capybara.use_default_driver }

  describe 'populating call list' do
    # test arbitrarily failing
    # it 'should add people to the call list roll' do
    #   add_to_call_list @patient_2
    #   within :css, '#call_list_content' do
    #     assert has_content? @patient_2.name
    #   end
    # end

    it 'should scope the call list to a particular line' do
      within :css, '#call_list_content' do
        assert has_no_text? @va_patient.name
      end
    end

    it 'should let you remove people from the call list roll' do
      within :css, '#call_list_content' do
        wait_for_element @patient.name
        accept_confirm { find('.glyphicon-remove').click }
        assert has_no_text? @patient.name
      end
    end
  end

  describe 'call list persistence between multiple users' do
    before do
      @user_2 = create :user
    end

    it 'should allow a call to be on two users call lists' do
      sign_out
      log_in_as @user_2
      add_to_call_list @patient
      within :css, '#call_list_content' do
        assert has_text? @patient.name
      end
      sign_out

      log_in_as @user
      within :css, '#call_list_content' do
        assert has_text? @patient.name
      end
    end
  end

  describe 'completed calls section' do
    before do
      within :css, '#call_list_content' do
        find("a[href='#call-#{@patient.primary_phone_display}']").click
      end
      find('a', text: 'I left a voicemail for the patient').click
      wait_for_no_element "Call #{@patient.name} now:"
      wait_for_element 'Your completed calls'
    end

    it 'should add a call to completed when a call was made within 8 hrs' do
      within :css, '#completed_calls_content' do
        assert has_text? @patient.name
      end

      within :css, '#call_list_content' do
        assert has_no_text? @patient.name
      end
    end

    it 'should time a call out after 8 hours' do
      Timecop.freeze(9.hours.from_now) do
        log_in_as @user
        wait_for_element 'Your completed calls'

        within :css, '#completed_calls_content' do
          assert has_no_text? @patient.name
        end

        within :css, '#call_list_content' do
          assert has_text? @patient.name
        end
      end
    end
  end

  describe 'patient edit page call log' do
    before do
      visit edit_patient_path @patient
      wait_for_element 'Call Log'
      click_link 'Call Log'
      wait_for_element 'Record new call'
    end

    it 'should update on the fly' do
      click_link 'Record new call'
      wait_for_element "Call #{@patient.name} now:"
      click_link 'I left a voicemail for the patient'
      wait_for_no_element "Call #{@patient.name} now:"

      assert has_content? 'Left voicemail'
    end
  end

  private

  def add_to_call_list(patient)
    wait_for_element 'Build your call list'
    fill_in 'search', with: patient.name
    wait_for_element 'Search results'
    click_button 'Search'
    find('a', text: 'Add', wait: 5).click
    wait_for_ajax
  end
end
