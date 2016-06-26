require 'test_helper'

class CallListTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @patient = create :patient, name: 'Susan Everyteen'
    @pregnancy = create :pregnancy, patient: @patient
    @patient_2 = create :patient, name: 'Thorny', primary_phone: '123-123-1235'
    @pregnancy_2 = create :pregnancy, patient: @patient_2
    @user = create :user
    log_in_as @user
    add_to_call_list @patient.name
  end

  after do
    Capybara.use_default_driver
  end

  describe 'populating call list' do
    it 'should add people to the call list roll' do
      within :css, '#call_list_content' do
        assert has_text? @patient.name
        assert has_link? 'Remove'
      end

      add_to_call_list @patient_2.name
      within :css, '#call_list_content' do
        assert has_text? @patient.name
        assert has_text? @patient_2.name
        assert has_link? 'Remove', count: 2
      end
    end

    it 'should let you remove people from the call list roll' do
      find('a', text: 'Remove').click
      within :css, '#call_list_content' do
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
      add_to_call_list @patient.name
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
        find("a[href='#call-123-123-1234']").click
      end
      find('a', text: 'I left a voicemail for the patient').click
      visit authenticated_root_path
    end

    it 'should add a call to completed when a call was made within 8 hrs' do
      within :css, '#completed_calls_content' do
        assert has_text? @patient.name
      end
    end

    it 'should time a call out after 8 hours' do
      puts Time.now
      Timecop.freeze.travel(8.hours.from_now) do
        puts Time.now
      end
    #     within :css, '#completed_calls_content' do
    #       assert has_no_text? @patient.name
    #     end
    #   end
    # end
  end

  private

  def add_to_call_list(patient_name)
    fill_in 'search', with: patient_name
    click_button 'Search'
    find('a', text: 'Add').click
  end
end
