require 'test_helper'

class RecordLookupTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    log_in_as @user
  end

  after do
    Capybara.use_default_driver
  end

  describe 'looking up someone who exists', js: true do
    before do
      @patient = create :patient, name: 'Susan Everyteen',
                                  primary_phone: '111-222-3333',
                                  other_contact: 'Yolo Goat',
                                  other_phone: '222-333-4455'
      @pregnancy = create :pregnancy, patient: @patient
    end

    it 'should have a functional search form' do
      assert_text 'Build your call list'
      assert has_button? 'Search'
      assert has_field? 'search'
    end

    it 'should retrieve and display a record' do
      fill_in 'search', with: 'susan everyteen'
      click_button 'Search'

      assert has_text? 'Search results'
      assert has_text? 'Susan Everyteen'
      assert_text @patient.primary_phone
    end

    it 'should be able to retrieve a record based on other name' do
      fill_in 'search', with: 'Yolo Goat'
      click_button 'Search'

      assert has_text? 'Search results'
      assert has_text? 'Susan Everyteen'
    end

    it 'should be able to retrieve a record based on other phone' do
      fill_in 'search', with: '222-333-4455'
      click_button 'Search'

      assert has_text? 'Search results'
      assert has_text? 'Susan Everyteen'
    end

    it 'should be able to retrieve a record regardless of phone formatting' do
      fill_in 'search', with: '(111)2223333'
      click_button 'Search'

      assert has_text? 'Search results'
      assert has_text? 'Susan Everyteen'
    end
  end

  describe 'looking for someone who does not exist', js: true do
    it 'should display new pregnancy partial with name' do
      fill_in 'search', with: 'Nobody Real Here'
      click_button 'Search'

      within :css, '#search_results_shell' do
        assert has_text? 'Your search produced no results, so add a new patient'
        assert_equal 'Nobody Real Here', find_field('Name').value
        assert has_no_text? 'Search results'
      end
    end

    it 'should display new pregnancy partial with phone' do
      fill_in 'search', with: '111-111-1112'
      click_button 'Search'

      within :css, '#search_results_shell' do
        assert has_text? 'Your search produced no results, so add a new patient'
        assert_equal '111-111-1112', find_field('Phone').value
      end
    end
  end
end
