require 'test_helper'

class CallsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = build :user
    puts @user
    sign_in @user
    @case = create :case
    @call = build :call
    puts @case
  end

  describe 'create method' do
    before do
      @call = attributes_for :call
    end

    it 'should create and save a new call' do
      assert_difference 'Case.find(@case).calls.count', 1 do
        post :create, call: @call, id: @case
      end
      assert_response :redirect
    end

    it 'should associate the new call with a case' do
    end

    it 'should redirect to the root path afterwards' do
      post :create, call: @call, id: @case
      assert_redirected_to root_path
    end

    it 'should not save if status is blank for some reason' do
    end

    it 'should reject other attributes besides status' do
    end

  end

end
