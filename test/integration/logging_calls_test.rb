require 'test_helper'

class LoggingCallsTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @patient = create :patient, name: 'Susan Everyteen'
    @pregnancy = create :pregnancy, patient: @patient
    @user = create :user
    log_in_as @user
    fill_in 'search', with: 'Susan Everyteen'
    click_button 'Search'
    find("a[href='#call-123-123-1234']").click
  end

  after do
    Capybara.use_default_driver
  end

  describe 'verifying modal behavior and content', js: true do
    it 'should open a modal when clicking the call glyphicon' do
      assert has_text? 'Call Susan Everyteen now'
      assert has_text? '123-123-1234'
      assert has_link? 'I reached the patient'
      assert has_link? 'I left a voicemail for the patient'
      assert has_link? "I couldn't reach the patient"
    end
  end

  describe 'logging reached patient', js: true do
    before do
      click_link 'I reached the patient'
      @pregnancy.reload
    end

    it 'should redirect to the edit view when a patient has been reached' do
      assert_equal current_path, edit_pregnancy_path(@pregnancy)
    end

    it 'should add a call when the patient has been reached' do
      click_link 'Dashboard'
      fill_in 'search', with: 'Susan Everyteen'
      click_button 'Search'
      find("a[href='#call-123-123-1234']").click
      assert_difference '@pregnancy.calls.count', 1 do
        click_link 'I reached the patient'
        @pregnancy.reload
      end
      assert_equal 'Reached patient', @pregnancy.calls.last.status
    end

    it 'should be viewable on the call log' do
      click_link 'Call Log'
      last_call = @pregnancy.calls.last

      within :css, '#call_log' do
        assert has_text? last_call.created_at.localtime.strftime('%-m/%d')
        assert has_text? last_call.created_at.localtime.strftime('%-l:%M %P')
        assert has_text? 'Reached patient'
        assert has_text? last_call.created_by.name
      end
    end
  end

  [].each do |call_status|
    describe "logging #{call_status}" do
      before do
      end

      it 'should close the modal' do
      end

      it 'should add a call to the pregnancy history' do
      end

      it 'should be vieable on the call log' do
      end
    end
  end
end
