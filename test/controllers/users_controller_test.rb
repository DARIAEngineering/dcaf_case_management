require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user, role: 'admin'
    @user_2 = create :user, role: 'cm', name: 'Billy Everyteen'
    @patient_1 = create :patient, name: 'Susan Everyteen'
    @patient_2 = create :patient, name: 'Yolo Goat'

    sign_in @user
  end

  describe 'authentication for restricted endpoints' do
    %w[users_path new_user_path].each do |endpoint|
      it "should redirect if user is not admin - #{endpoint}" do
        User.role.values.reject { |role| role == :admin }.each do |role|
          @user.update role: role
          get send(endpoint.to_sym)
          assert_response :redirect
        end
      end
    end

    %w[admin data_volunteer cm].each do |endpoint|
      it "should redirect if user is not admin - #{endpoint}" do
        User.role.values.reject { |role| role == :admin }.each do |role|
          @user.update role: role
          patch send("change_role_to_#{endpoint}_path".to_sym, @user_2)
          assert_response :redirect
        end
      end
    end

    it 'should respond unauthorized if user is not admin - users_search' do
      User.role.values.reject { |role| role == :admin }.each do |role|
        @user.update role: role
        post users_search_path, params: { search: '' }, xhr: true
        assert_response :unauthorized
      end
    end

    it 'should redirect if user is not admin - user update' do
      User.role.values.reject { |role| role == :admin }.each do |role|
        @user.update role: role
        patch user_path(@user_2), params: { user: {} }
        assert_response :redirect
      end
    end

    it 'should respond unauthorized if user is not admin - user update' do
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
    it 'should let admins access the route' do
      get users_path
      assert_response :success
    end
  end

  describe 'edit method' do
    it 'should be accessible' do
      get edit_user_path(@user)
      assert_response :success
    end
  end

  describe 'search method' do
    it 'should work on empty search' do
      post users_search_path, params: { search: '' }, xhr: true
      assert_response :success
    end

    it 'should work on nonempty search' do
      post users_search_path, params: { search: 'yolo' }, xhr: true
      assert_response :success
    end
  end

  describe 'new method' do
    it 'should return success' do
      get new_user_path
      assert_response :success
    end
  end

  describe 'create method' do
    it 'should create a user' do
      attributes = attributes_for(:user)
      attributes.delete :role
      assert_difference 'User.count', 1 do
        post users_path, params: { user: attributes }
      end
    end

    it 'should show errors if creation fails' do
      attributes = attributes_for(:user)
      attributes[:name] = nil
      assert_no_difference 'User.count' do
        post users_path, params: { user: attributes }
      end
      assert_includes response.body, 'can&#39;t be blank'
    end
  end

  describe 'update method' do
    before do
      @params = {
        name: 'jimmy',
        email: 'jimmy@hotmail.com'
      }
    end

    describe 'successful updates' do
      before do
        patch user_path(@user_2), params: { user: @params }
        @user_2.reload
      end

      it 'should respond redirect in completion and flash' do
        assert_response :redirect
        assert_equal 'Successfully updated user details', flash[:notice]
      end

      it 'should update fields' do
        assert_equal 'jimmy', @user_2.name
        assert_equal 'jimmy@hotmail.com', @user_2.email
      end
    end

    describe 'failed updates' do
      before do
        @params[:name] = nil
        patch user_path(@user_2), params: { user: @params }
        @user_2.reload
      end

      it 'should not update parameters' do
        assert_equal 'Billy Everyteen', @user_2.name
      end

      it 'should flash an error' do
        assert_equal "Error saving user details - Name can't be blank",
                     flash[:alert]
      end
    end
  end

  describe 'user role endpoints' do
    it 'should let you change a user to an admin' do
      patch change_role_to_admin_path(@user_2)
      @user_2.reload
      assert_equal 'admin', @user_2.role
    end

    %w(data_volunteer cm).each do |role|
      it "should let you change another user - #{role}" do
        patch send("change_role_to_#{role}_path".to_sym, @user_2)
        @user_2.reload
        assert_equal role, @user_2.role
      end

      it "should not let you demote yourself - #{role}" do
        patch send("change_role_to_#{role}_path".to_sym, @user)
        @user.reload
        assert_includes flash[:alert], 'For safety reasons'
        assert_equal 'admin', @user.role
      end
    end
  end

  describe 'toggle_lock method' do
    it 'should prevent current users from locking themselves' do
      post toggle_disabled_path(@user)
      @user.reload
      refute @user.disabled_by_fund?
    end

    it 'should toggle locked status from false to true' do
      refute @user_2.disabled_by_fund?
      post toggle_disabled_path(@user_2)
      @user_2.reload
      assert @user_2.disabled_by_fund?
    end
  end

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
