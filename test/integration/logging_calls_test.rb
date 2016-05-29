require 'test_helper'

class LoggingCallsTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @patient = create :patient, name: 'Susan Everyteen'
    @pregnancy = create :pregnancy, patient: @patient
    @user = create :user
    log_in_as @user
  end

  describe 'logging a reached patient', js: true do
    before do
      fill_in 'search', with: 'Susan Everyteen'
      click_button 'Search'
    end

    it 'should open a modal when clicking the call glyphicon' do
      find("a[href='#call-123-123-1234']").click
      assert has_text? 'Call Susan Everyteen now'
      assert has_text? '123-123-1234'
      assert has_link? 'I reached the patient'
      assert has_link? 'I left a voicemail for the patient'
      assert has_link? "I couldn't reach the patient"
    end
  end

  # describe 'logging a VM or a not home', js: true do 

  # end
end
