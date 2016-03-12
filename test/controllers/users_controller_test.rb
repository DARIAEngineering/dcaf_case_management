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
    it 'should respond successfully' do 
      patch :add_pregnancy, id: @pregnancy_1, user_id: @user, format: :js
      assert_response :success
    end

    it 'should add a patient to a users call list' do 
      patch :add_pregnancy, id: @pregnancy_1, user_id: @user, format: :js
      assert_equal @user.pregnancies.count, 1
      assert_difference '@user.pregnancies.count', 1 do
        patch :add_pregnancy, id: @pregnancy_2, user_id: @user, format: :js
      end
      assert_equal @user.pregnancies.count, 2
    end

    it 'should should return bad request on sketch ids' do 
      patch :add_pregnancy, id: '12345678', user_id: @user, format: :js
      assert_response :bad_request
    end

  end

  describe 'remove_pregnancy method' do 
  end

  describe 'get_user_and_pregnancy method' do 
  end
end
