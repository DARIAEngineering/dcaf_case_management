require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
    @patient_1 = create :patient, name: 'Susan Everyteen'
    create :pregnancy, patient: @patient_1
    @patient_2 = create :patient, name: 'Yolo Goat'
    create :pregnancy, patient: @patient_2
  end

  describe 'create method' do
    it 'should raise if user is not admin' do
      @user.role = :cm
      @user.save!
      assert_raise RuntimeError, 'Permission Denied' do
        post :create
      end
    end
  end

  describe 'add_patient method' do
    before do
      patch :add_patient, id: @patient_1, user_id: @user, format: :js
    end

    it 'should respond successfully' do
      assert_response :success
    end

    it 'should add a patient to a users call list' do
      @user.reload
      assert_equal @user.patients.count, 1
      assert_difference '@user.patients.count', 1 do
        patch :add_patient, id: @patient_2, user_id: @user, format: :js
        @user.reload
      end
      assert_equal @user.patients.count, 2
    end

    it 'should not adjust the count if a patient is already in the list' do
      assert_no_difference '@user.patients.count' do
        patch :add_patient, id: @patient_1, user_id: @user, format: :js
      end
    end

    it 'should should return bad request on sketch ids' do
      patch :add_patient, id: '12345678', user_id: @user, format: :js
      assert_response :bad_request
    end
  end

  describe 'remove_patient method' do
    before do
      patch :add_patient, id: @patient_1, user_id: @user, format: :js
      patch :add_patient, id: @patient_2, user_id: @user, format: :js
      patch :remove_patient, id: @patient_1, user_id: @user, format: :js
      @user.reload
    end

    it 'should respond successfully' do
      assert_response :success
    end

    it 'should remove a patient' do
      assert_difference '@user.patients.count', -1 do
        patch :remove_patient, id: @patient_2, user_id: @user, format: :js
        @user.reload
      end
    end

    it 'should do nothing if the patient is not currently in the call list' do
      assert_no_difference '@user.patients.count' do
        patch :remove_patient, id: @patient_1, user_id: @user, format: :js
      end
      assert_response :success
    end

    it 'should should return bad request on sketch ids' do
      patch :remove_patient, id: '12345678', user_id: @user, format: :js
      assert_response :bad_request
    end
  end

  describe 'reorder call list' do
    before do
      @ids = []
      4.times { @ids << create(:patient)._id.to_s }
      @ids.shuffle!

      patch :reorder_call_list, order: @ids, format: :js
      @user.reload
    end

    it 'should respond success' do
      assert_response :success
    end

    it 'should populate the user call order field' do
      assert_not_nil @user.call_order
      assert_equal @ids, @user.call_order
    end
  end

  it 'should be the devise controller' do
    assert :devise_controller?
  end
end
