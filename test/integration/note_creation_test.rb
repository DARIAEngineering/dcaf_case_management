require 'test_helper'

class NoteCreationTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    log_in_as @user
    @patient = create :patient
    @pregnancy = create :pregnancy, patient: @patient
    visit edit_pregnancy_path(@pregnancy)
  end

  describe 'add patient pregnancy notes' do
    it 'should display a case notes form and current notes' do
      click_link 'Notes'
      within('#notes') do
        assert_text 'Notes' # confirm notes header is visible
        page.has_field? 'note[full_text]'
        assert has_button? 'Create Note'
      end
    end

    it 'should let you add a new case note' do
      fill_in 'note[full_text]', with: 'Sample new note creation body'
      click_button 'Create Note'
      assert_text 'Sample new note creation body'
    end
  end
end
