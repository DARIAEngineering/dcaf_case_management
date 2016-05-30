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

  ['Left voicemail', "Couldn't reach patient"].each do |call_status|
    describe "logging #{call_status}", js: true do
      before do
        if call_status == 'Left voicemail'
          @link_text = 'I left a voicemail for the patient'
        elsif call_status == "Couldn't reach patient"
          @link_text = "I couldn't reach the patient"
        else
          raise 'Not a recognized call status'
        end
      end

      it "should close the modal when clicking #{call_status}" do
        click_link @link_text
        assert_equal current_path, authenticated_root_path
        assert has_no_text? 'Call Susan Everyteen now'
        assert has_no_link? @link_text
      end

      it "should add a call to the pregnancy history when clicking #{call_status}" do
        # occasionally, these tests will randomly fail due to a threading issue
        @pregnancy.reload
        assert_difference '@pregnancy.reload.calls.count', 1 do
          click_link @link_text
          sleep 1 # Yes, I know EXACTLY how annoying this is
        end
        assert_equal call_status, @pregnancy.calls.last.status
      end

      it "should be visible on the call log after clicking #{call_status}" do
        click_link @link_text
        click_link 'Susan Everyteen'
        click_link 'Call Log'
        last_call = @pregnancy.reload.calls.last

        within :css, '#call_log' do
          assert has_text? last_call.created_at.localtime.strftime('%-m/%d')
          assert has_text? last_call.created_at.localtime.strftime('%-l:%M %P')
          assert has_text? call_status
          assert has_text? last_call.created_by.name
        end
      end
    end
  end
end
