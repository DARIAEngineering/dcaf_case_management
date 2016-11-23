require 'test_helper'

class SelectLineTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    log_in @user
  end

  describe 'line selection process' do
    it 'should redirect to line selection page on login' do
      assert has_content? 'DC'
      assert has_content? 'MD'
      assert has_content? 'VA'
      assert has_button? 'Select your line for this session'
    end

    it 'should redirect to the main dashboard after line set' do
      choose 'DC'
      click_button 'Select your line for this session'
      assert_equal current_path, authenticated_root_path
      assert has_content? 'Line: DC'
    end
  end

  describe 'redirection conditions' do
    it 'should redirect from dashboard if no line is set' do
      visit authenticated_root_path
      assert_equal current_path, lineselect_path
    end

    it 'should let you change your line once line is set' do
      choose 'DC'
      click_button 'Select your line for this session'
      assert has_content? 'Line: DC'

      click_link 'Line: DC'
      assert has_content? 'MD'
      assert_equal current_path, lineselect_path
      choose 'MD'
      click_button 'Select your line for this session'
      assert has_content? 'Line: MD'
    end
  end
end
