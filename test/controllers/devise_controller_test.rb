require 'test_helper'

class DeviseControllerTest < ActionController::TestCase
  describe 'attribute whitelisting beyond the devise minimum' do 
    before do 
      @user_attributes = { email: "billy2@everyteen.com", password: "password" }
    end

    # confirm that each permitted parameter is allowed
    %w(name).each do |whitelisted_attribute|
      it "should permit #{whitelisted_attribute} in sign up" do
        # p @user_2
        # p devise_parameter_sanitizer.for(:sign_up)
        # p permitted_parameters
      end

      it "should permit #{whitelisted_attribute} in account_update" do 
        @user_attributes.merge!({ whitelisted_attribute.to_sym => 'thing'})
        post user_registration_path, user: @user_attributes
        assert_response :success
      end
    end
    
    it 'should reject non-whitelisted attributes' do 
    end

  end
end
