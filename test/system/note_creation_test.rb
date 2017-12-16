require 'application_system_test_case'

# Confirm that notes on a patient can be created
class NoteCreationTest < ApplicationSystemTestCase
  before do
    @user = create :user
    log_in_as @user
    @patient = create :patient
    visit edit_patient_path(@patient)
    wait_for_element 'Notes'
    click_link 'Notes'
  end

  describe 'add patient notes' do
    it 'should display a case notes form and current notes' do
      within('#notes') do
        assert has_text? 'Notes'
        assert has_button? 'Create Note'
      end
    end

    it 'should let you add a new case note' do
      fill_in 'note[full_text]', with: 'Sample new note creation body'
      click_button 'Create Note'
      within('#notes_log') do
        assert has_text? 'Sample new note creation body'
      end
    end
  end
end
