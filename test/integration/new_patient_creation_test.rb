require 'test_helper'

class NewPatientCreationTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    log_in_as @user
  end

  after do
    Capybara.use_default_driver
  end

  describe 'creating and recalling a new patient' do
    before do
      fill_in 'search', with: 'Nobody Real Here'
      click_button 'Search'
      fill_in 'Phone Number', with: '555-666-7777'
      fill_in 'Name', with: 'Susan Everyteen 2'
      fill_in 'Initial Call Date', with: '03/04/2016'

      page.save_screenshot '~/Desktop/capybara.png'
      click_button 'Create new patient'
    end

    it 'should ' do
    end

  end
end
