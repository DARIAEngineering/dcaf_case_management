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
      post :create, id: @pregnancy, note: @note, format: :js
    end

    it 'should create and save a new note' do 
      assert_difference 'Pregnancy.find(@pregnancy).notes.count', 1 do 
        post :create, id: @pregnancy, note: @note, format: :js
      end
    end

    it 'should respond success if the note submits' do 
      assert_response :success
    end

    it 'should render create.js.erb if it successfully saves' do
      assert_template 'notes/create'
    end

    it 'should log the creating user' do 
      assert_equal Pregnancy.find(@pregnancy).notes.last.created_by, @user
    end

    # should fail gracefully if no full text
    # should fail gracefully if no pregnancy
  end

  describe 'update method' do 
    # should render template
    # should respond success
    # should actually update field
    # should have an audit trail
    # should fail gracefully on setting note content to blank 
    # should fail gracefully on no pregnancy
  end
end
