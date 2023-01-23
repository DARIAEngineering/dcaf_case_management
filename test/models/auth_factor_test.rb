require 'test_helper'

class AuthFactorTest < ActiveSupport::TestCase
  before do
    @user = create :user
    with_versioning(@user) do
      @user.auth_factors.create attributes_for(:auth_factor, :registration_complete)
      @auth_factor = @user.auth_factors.first
    end
  end

  describe 'validations' do
    it 'should build' do
      assert @auth_factor.valid?
    end
  end

  describe 'relationships' do
    it 'should be linkable to a user' do
      assert_equal @auth_factor.created_by, @user
    end
  end
end
