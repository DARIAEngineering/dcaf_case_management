require 'test_helper'

class CallsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = build :user
    puts @user
    sign_in @user
    @case = build :case
    @call = build :call
    puts @case
  end

  describe 'create method' do
    it 'should create and save a new call' do
      call = attributes_for :call
      puts call
      post :create, call: call
    end

    it 'should associate the new call with a case' do
    end

    it 'should redirect to the root path afterwards' do
    end

    it 'should not save if status is blank for some reason' do
    end

    it 'should reject other attributes besides status' do
    end

  end

end
