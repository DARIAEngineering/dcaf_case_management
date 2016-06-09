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
      fill_in 'Phone', with: '555-666-7777'
      fill_in 'Name', with: 'Susan Everyteen 2'
      fill_in 'Initial Call Date', with: '03/04/2016'
      find('button', text: /Create new patient/).trigger('click')
      sleep 1
      fill_in 'search', with: 'Susan Everyteen 2'
      click_button 'Search'
    end

    it 'should make that patient retrievable via search' do
      within :css, '#search_results' do
        assert has_text? 'Susan Everyteen 2'
        assert has_text? '555-666-7777'
      end
    end

    it 'should make them viewable from the pregnancy edit page' do
      click_link 'Susan Everyteen 2'
      assert current_path, edit_pregnancy_path(Pregnancy.last)
    end
  end
end
