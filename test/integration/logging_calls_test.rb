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
      @timestamp = Time.zone.now
      find('a', text: 'I reached the patient').click
    end

    it 'should redirect to the edit view when a patient has been reached' do
      has_text? 'Submit pledge' # wait for the page to load
      assert_equal current_path, edit_pregnancy_path(@pregnancy)
    end

    it 'should be viewable on the call log' do
      find('a', text: 'Call Log').click

      within :css, '#call_log' do
        assert has_text? @timestamp.display_date
        assert has_text? @timestamp.display_time
        assert has_text? 'Reached patient'
        assert has_text? @user.name
      end
    end

    it 'should be able to save more than one reached patient call' do
      visit authenticated_root_path
      fill_in 'search', with: 'Susan Everyteen'
      click_button 'Search'
      find("a[href='#call-123-123-1234']").click
      click_link 'I reached the patient'
      find('a', text: 'Call Log').click
      within :css, '#call_log' do
        assert has_content? 'Reached patient', count: 2
      end
    end
  end

  ['Left voicemail', "Couldn't reach patient"].each do |call_status|
    describe "logging #{call_status}", js: true do
      before do
        @link_text =  if call_status == 'Left voicemail'
                        'I left a voicemail for the patient'
                      elsif call_status == "Couldn't reach patient"
                        "I couldn't reach the patient"
                      else
                        raise 'Not a recognized call status'
                      end
        @timestamp = Time.zone.now
        find('a', text: @link_text).click
      end

      it "should close the modal when clicking #{call_status}" do
        assert_equal current_path, authenticated_root_path
        assert has_no_text? 'Call Susan Everyteen now'
        assert has_no_link? @link_text
      end

      it "should be visible on the call log after clicking #{call_status}" do
        assert_equal current_path, authenticated_root_path
        visit edit_pregnancy_path(@pregnancy)
        find('a', text: 'Call Log').click

        within :css, '#call_log' do
          assert has_text? @timestamp.display_date
          assert has_text? @timestamp.display_time
          assert has_text? call_status
          assert has_text? @user.name
        end
      end
    end
  end
end
