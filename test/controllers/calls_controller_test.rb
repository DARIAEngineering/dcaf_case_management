require 'test_helper'

class CallsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = build :user
    sign_in @user
    @case = create :case
    @call = build :call
  end

  describe 'create method' do
    before do
      @call = attributes_for :call
    end

    it 'should create and save a new call' do
      assert_difference 'Case.find(@case).calls.count', 1 do
        post :create, status: @call.status, id: @case
      end
      assert_response :redirect
    end

    # If we have to look up the call through a case this test seems redundant
    # I.e. I think the previous test also confirms the association
    # it 'should associate the new call with a case' do
    #   post :create, status: @call.status, id: @case
    #   assert_equal Case.find(@case).calls.last.case, @case
    #   assert_includes Case.find(@case).calls, Case.find(@case).calls.last
    # end

    it 'should redirect to the root path afterwards' do
      post :create, status: @call.status, id: @case
      assert_redirected_to root_path
    end

    it 'should not save if status is blank for some reason' do
      assert_no_difference 'Case.find(@case).calls.count' do
        post :create, status: nil, id: @case
      end
    end

    it 'should reject other attributes besides status' do
      post :create, status: @call.status, other: "extraneous attribute", id: @case
      assert_not_respond_to Case.find(@case).calls.last, :other
    end

  end

end
