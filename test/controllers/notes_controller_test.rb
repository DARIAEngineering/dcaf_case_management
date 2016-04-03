require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  before do 
    @user = create :user
    sign_in @user
    @pregnancy = create :pregnancy
  end

  describe 'create method' do 
    before do
      @note = attributes_for :note, full_text: 'This is a note'
      post :create, id: @pregnancy, note: @note#, format: :js
    end

    it 'should create and save a new note' do 
      assert_difference 'Pregnancy.find(@pregnancy).notes.count', 1 do 
        post :create, id: @pregnancy, note: @note#, format: :js
      end
    end
  end

  describe 'update method' do 
  end
end
