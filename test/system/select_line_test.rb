require 'application_system_test_case'

# Tests around line selection behavior
class SelectLineTest < ApplicationSystemTestCase
  before do
    @user = create :user
    create :line, name: 'DC'
    create :line, name: 'MD'
    create :line, name: 'VA'
    log_in @user
  end

  describe 'line selection process' do
    it 'should redirect to line selection page on login' do
      assert_equal current_path, new_line_path
      assert has_content? 'DC'
      assert has_content? 'MD'
      assert has_content? 'VA'
      assert has_button? 'Get started'
    end

    it 'should redirect to the main dashboard after line set' do
      choose 'DC'
      click_button 'Get started'
      assert_equal current_path, authenticated_root_path
      assert has_content? 'Your current line: DC'
    end
  end

  describe 'redirection conditions' do
    before { @patient = create :patient }
    it 'should redirect from dashboard if no line is set' do
      visit edit_patient_path(@patient) # no redirect
      assert_equal current_path, edit_patient_path(@patient)
      visit authenticated_root_path # back to dashboard
      assert_equal current_path, new_line_path
    end
  end
end
