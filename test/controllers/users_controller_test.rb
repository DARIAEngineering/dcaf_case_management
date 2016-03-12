require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    sign_in @user
    @patient_1 = create :patient, name: 'Susan Everyteen'
    @pregnancy_1 = create :pregnancy, patient: @patient_1
    @patient_2 = create :patient, name: 'Yolo Goat'
    @pregnancy_2 = create :pregnancy, patient: @patient_2
  end

  describe 'add_pregnancy method' do
    it 'should do a thing' do 
      patch :add_pregnancy, id: @pregnancy_1, user_id: @user, format: :js
    end
  end

  describe 'remove_pregnancy method' do 
  end

  describe 'get_user_and_pregnancy method' do 
  end
end
