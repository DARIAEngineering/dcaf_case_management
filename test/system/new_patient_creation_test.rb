require 'application_system_test_case'

# Confirm that new patients can be created
class NewPatientCreationTest < ApplicationSystemTestCase
  before do
    @line1 = create :line
    @line2 = create :line
    @line3 = create :line
    @user = create :user
    log_in_as @user, @line2

    fill_in 'search', with: 'Nobody Real Here'
    click_button 'Search'
    fill_in 'Phone', with: '555-666-7777'
    fill_in 'Name', with: 'Susan Everyteen 2'
    fill_in 'Initial Call Date', with: '03/04/2016'
    select @line2.name, from: 'Line'
    click_button 'Add new patient'
    wait_for_ajax
  end

  describe 'creating and recalling a new patient' do
    it 'should make that patient retrievable via search' do
      fill_in 'search', with: 'Susan Everyteen 2'
      click_button 'Search'

      within :css, '#search_results_shell' do
        assert has_text? 'Susan Everyteen 2'
        assert has_text? '555-666-7777'
      end
    end

    it 'should make them viewable from the patient edit page' do
      fill_in 'search', with: 'Susan Everyteen 2'
      click_button 'Search'
      click_link 'Susan Everyteen 2'
      assert current_path, edit_patient_path(Patient.last)
    end
  end

  describe 'endpoint behavior' do
    it 'should redirect to the root path' do
      assert_equal current_path, authenticated_root_path
    end

    it 'should autopopulate the call list' do
      within :css, '#call_list' do
        assert has_link? 'Susan Everyteen 2'
      end
    end

    it 'should only be viewable on that line' do
      [@line1, @line3].each do |line|
        sign_out
        log_in_as @user, line

        fill_in 'search', with: 'Susan Everyteen 2'
        click_button 'Search'
        refute has_text? '555-666-7777'
        assert has_text? 'Your search produced no results'
      end
    end
  end
end
