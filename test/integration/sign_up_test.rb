require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest
  before do
    visit root_path
    click_link 'Sign up'
  end

  describe 'creating a new user' do 
    it 'should work' do 
      fill_in 'Email', with: 'billy.everyteen@gmail.com'
      fill_in 'Name', with: 'A Real Person'
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      click_button 'Sign up'
    end
  end












  # describe 'attribute whitelisting beyond the devise minimum' do 
  #   before do 
  #     @user_attributes = { email: "billy2@everyteen.com", password: "password" }
  #   end

  #   # confirm that each permitted parameter is allowed
  #   %w(name).each do |whitelisted_attribute|
  #     it "should permit #{whitelisted_attribute} in sign up" do
  #       @user_attributes.merge!({ whitelisted_attribute.to_sym => 'thing'})
  #       @request.env["devise.mapping"] = Devise.mappings[:user]
  #       post :create, controller: 'devise/registrations', user: @user_attributes
  #       # assert_response :success


  #       # p @user_2
  #       # p request.env
  #     end

  #     it "should permit #{whitelisted_attribute} in account_update" do 
  #     end
  #   end
    
  #   it 'should reject non-whitelisted attributes' do 
  #   end

  # end

end
