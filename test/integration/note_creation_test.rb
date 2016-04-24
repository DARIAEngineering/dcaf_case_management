require 'test_helper'

class NotesCreationTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    log_in_as @user
    @patient = create :patient
    @pregnancy = create :pregnancy, appointment_date: nil, patient: @patient
    visit edit_pregnancy_path(@pregnancy)
  end
 
  describe 'add patient pregnancy notes' do
    it 'should display a pregnancy notes form and current notes' do
        click_link 'Notes'
        
        visit current_path 
        
        within('#notes')do
            assert_text 'Notes' #confirm notes header is visible 
            assert has_button? 'Create Note'
        end
    end 
    
    it 'should let you add a new pregnancy note' do
        fill_in 'note[full_text]', with: 'Sample Note Body'
       
        assert_difference 'Note.count', 1 do 
          click_on 'Create Note'
        end 
        
        visit current_path 
        
        assert_text 'Sample Note Body'
    end 

    # it 'should let you edit a pregnancy note' do
    #     click_on 'edit'
    #     fill_in 'note[full_text]', with: 'Sample Note Body Edit'
    #     click_on 'Create Note'
        
    #     visit current_path
        
    #     assert_text 'Sample Note Body Edit'
    # end 
  end 
end 