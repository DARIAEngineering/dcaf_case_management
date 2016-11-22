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

    it 'should let you select a line' do
      assert false
    end

    it 'should redirect to the main dashboard after line set' do
      assert false
    end
  end

  describe 'redirection conditions' do
    it 'should redirect from dashboard if no line is set' do
      assert false
    end

    it 'should let you change your line once line is set' do
      assert false
    end
  end
end
