require 'test_helper'

class RenderNewPatientPartial < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    log_in_as @user
    @patient = create :patient, name: 'Susan Everyteen',
                                primary_phone: '111-222-3333',
                                other_contact: 'Yolo Goat',
                                other_phone: '222-333-4455'
    @pregnancy = create :pregnancy, patient: @patient
  end

  after do
    Capybara.use_default_driver
  end

  describe 'returning no results from a search', js: true do
    it 'should display the new patient partial without search results' do
      fill_in 'search', with: 'Nobody Real Here'
      click_button 'Search'

      refute has_text? 'Search results'
      within :css, '#search_results_shell' do
        assert has_text? 'Add a new patient'
        assert_equal 'Nobody Real Here', find_field('Name').value, find_field('Name').value
      end
    end
  end

  describe 'returning a partial match in a search', js: true do
    it 'should display the partial match record and the new patient partial' do
      fill_in 'search', with: 'susan every'
      click_button 'Search'

      assert has_text? 'Search results'
      assert has_text? 'Susan Everyteen'
      within :css, '#search_results_shell' do
        assert has_text? 'Add a new patient'
        assert_equal 'susan every', find_field('Name').value
      end
    end
  end
  
  describe 'returning an exact match in a search', js: true do
    it 'should display the exact match record and the new patient partial' do
      fill_in 'search', with: 'Susan Everyteen'
      click_button 'Search'

      assert has_text? 'Search results'
      assert has_text? 'Susan Everyteen'
      within :css, '#search_results_shell' do
        assert has_text? 'Add a new patient'
        assert_equal 'Susan Everyteen', find_field('Name').value
      end
    end
  end
end
