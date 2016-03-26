require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
    @patient_1 = create :patient, name: 'Susan Everyteen'
    @pregnancy_1 = create :pregnancy, patient: @patient_1
    @patient_2 = create :patient, name: 'Yolo Goat'
    @pregnancy_2 = create :pregnancy, patient: @patient_2
  end

  describe 'add_pregnancy method' do
    before do
      patch :add_pregnancy, id: @pregnancy_1, user_id: @user, format: :js
    end

    it 'should respond successfully' do
      assert_response :success
    end

    it 'should add a patient to a users call list' do
      assert_equal @user.pregnancies.count, 1
      assert_difference '@user.pregnancies.count', 1 do
        patch :add_pregnancy, id: @pregnancy_2, user_id: @user, format: :js
      end
      assert_equal @user.pregnancies.count, 2
    end

    it 'should not adjust the count if a pregnancy is already in the list' do
      assert_no_difference '@user.pregnancies.count' do
        patch :add_pregnancy, id: @pregnancy_1, user_id: @user, format: :js
      end
    end

    it 'should should return bad request on sketch ids' do
      patch :add_pregnancy, id: '12345678', user_id: @user, format: :js
      assert_response :bad_request
      patch :add_pregnancy, id: @pregnancy_1, user_id: 'bronsonmissouri', format: :js
      assert_response :bad_request
    end
  end

  describe 'remove_pregnancy method' do
    before do
      patch :add_pregnancy, id: @pregnancy_1, user_id: @user, format: :js
      patch :add_pregnancy, id: @pregnancy_2, user_id: @user, format: :js
      patch :remove_pregnancy, id: @pregnancy_1, user_id: @user, format: :js
    end

    it 'should respond successfully' do
      assert_response :success
    end

    it 'should remove a pregnancy' do
      assert_difference '@user.pregnancies.count', -1 do
        patch :remove_pregnancy, id: @pregnancy_2, user_id: @user, format: :js
      end
    end

    it 'should do nothing if the pregnancy is not currently in the call list' do
      assert_no_difference '@user.pregnancies.count' do
        patch :remove_pregnancy, id: @pregnancy_1, user_id: @user, format: :js
      end
      assert_response :success
    end

    it 'should should return bad request on sketch ids' do
      patch :remove_pregnancy, id: '12345678', user_id: @user, format: :js
      assert_response :bad_request
      patch :remove_pregnancy, id: @pregnancy_1, user_id: 'bronsonmissouri', format: :js
      assert_response :bad_request
    end
  end
end
