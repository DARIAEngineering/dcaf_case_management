require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @user_2 = create :user
    sign_in @user
    @patient_1 = create :patient, name: 'Susan Everyteen'
    @patient_2 = create :patient, name: 'Yolo Goat'
  end

  describe 'create method' do
    it 'should raise if user is not admin' do
      User.role.values.reject { |role| role == :admin }.each do |role|
        @user.update role: role
        assert_no_difference 'User.count' do
          post users_path, params: { user: attributes_for(:user) }
        end
        assert_response :unauthorized
      end
    end
  end

  describe 'index method' do
    it 'should redirect if user is not admin' do
      User.role.values.reject { |role| role == :admin }.each do |role|
        @user.update role: role
        get users_path
        assert_response :redirect
      end
    end

    it 'should let admin access the route' do
      @user.role = :admin
      @user.save!
      get users_path
      assert_response :success
    end
  end

  describe 'search method' do
    it 'should return success' do
      post users_search_path, params: { search: '' }, xhr: :true
      assert_response :success
    end
  end

  # TODO this is DEFINITELY busted. break it up into multiple tests, the whole flow is weird
  # describe 'when a users password is changed' do
  #   it 'should send an email' do
  #     post user_password_path, params: { user: @user.email }
  #     assert sends email if it works, doesn't send an email if user not present
  #     assert redirects to root url

  #     get  user passwords path with the specialized key
  #     assert success

  #     using whatever key, post to user_password_path
  #     email_content = ActionMailer::Base.deliveries.last
  #     assert_match /Your DARIA password has changed/, email_content.subject.to_s
  #     assert_match @user.email, email_content.to_s
  #   end
  # end

  # TODO test
  # describe 'toggle_lock method' do
  #   before do
  #     @user_2 = create :user, name: 'John Smith', email: 'john@smith.com'
  #   end
  #
  #   it 'should respond successfully' do
  #     assert_response :redirect
  #   end
  #
  #   it 'should prevent current users from locking themselves' do
  #     get toggle_lock_path(@user)
  #     @user.reload
  #     assert_equal @user.access_locked?, false
  #   end
  #
  #   it 'should toggle locked status from false to true' do
  #     assert_equal @user_2.access_locked?, false
  #     get toggle_lock_path(@user_2)
  #     @user_2.reload
  #     assert_equal @user_2.access_locked?, true
  #   end
  #
  #   it 'should flash success' do
  #     get toggle_lock_path(@user_2)
  #     assert_equal "Successfully locked " + @user_2.email, flash[:notice]
  #   end
  # end

  # describe 'reset_password method' do
  #   before do
  #     get reset_password_path(@user)
  #   end

  #   it 'should redirect on success' do
  #     assert_response :redirect
  #   end

  #   it 'should flash success' do
  #     assert_equal 'Successfully sent password reset instructions to ' + @user.email, flash[:notice]
  #   end
  # end

  describe 'update method' do
    before do
      @params = {
        name: 'jimmy',
        email: 'jimmy@hotmail.com'
      }

      patch user_path(@user), params: { user: @params }
      @user.reload
    end

    it 'should respond redirect in completion' do
      assert_response :redirect
    end

    it 'should NOT update parameters' do
      assert_equal @user.name, 'Billy Everyteen'
    end

    it 'should NOT flash success' do
      assert_nil flash[:notice]
    end

    # TODO
    # it 'should update if ADMIN' do
    #   @user.update role: :admin
    #   @user.reload
    #   patch user_path(@user_2), params: { user: @params }
    #
    #   assert_equal @user_2.name, 'jimmy'
    #   assert_equal @user_2.email, 'jimmy@hotmail.com'
    # end
  end

  describe 'add_patient method' do
    before do
      patch add_patient_path(@user, @patient_1), xhr: true
    end

    it 'should respond successfully' do
      assert_response :success
    end

    it 'should add a patient to a users call list' do
      @user.reload
      assert_equal @user.patients.count, 1
      assert_difference '@user.patients.count', 1 do
        patch add_patient_path(@user, @patient_2), xhr: true
        @user.reload
      end
      assert_equal @user.patients.count, 2
    end

    it 'should not adjust the count if a patient is already in the list' do
      assert_no_difference '@user.patients.count' do
        patch add_patient_path(@user, @patient_1), xhr: true
      end
    end

    it 'should should return bad request on sketch ids' do
      patch add_patient_path(@user, 'nopatient'), xhr: true
      assert_response :bad_request
    end
  end

  describe 'remove_patient method' do
    before do
      patch add_patient_path(@user, @patient_1), xhr: true
      patch add_patient_path(@user, @patient_2), xhr: true
      patch remove_patient_path(@user, @patient_1), xhr: true
      @user.reload
    end

    it 'should respond successfully' do
      assert_response :success
    end

    it 'should remove a patient' do
      assert_difference '@user.patients.count', -1 do
        patch remove_patient_path(@user, @patient_2), xhr: true
        @user.reload
      end
    end

    it 'should do nothing if the patient is not currently in the call list' do
      assert_no_difference '@user.patients.count' do
        patch remove_patient_path(@user, @patient_1), xhr: true
      end
      assert_response :success
    end

    it 'should should return bad request on sketch ids' do
      patch remove_patient_path(@user, 'whatever'), xhr: true
      assert_response :bad_request
    end
  end

  describe 'reorder call list' do
    before do
      @ids = []
      4.times { @ids << create(:patient)._id.to_s }
      @ids.shuffle!

      patch reorder_call_list_path, params: { order: @ids }, xhr: true
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

  describe 'devise controller customization' do
    it 'should be the devise controller' do
      assert :devise_controller?
    end

    it 'should not let you edit email' do
      params = { email: 'nope@nope.com', current_password: @user.password }
      put registration_path, params: { user: params }
      @user.reload
      refute_equal @user.email, 'nope@nope.com'
    end
  end
end
