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

  describe 'cleanup of incomplete registrations' do
    before do
      @incomplete_old = @user.auth_factors.build(
        channel: 'sms',
        registration_complete: false
      )
      @incomplete_old.save!(validate: false)
      @incomplete_old.update_column(:created_at, 2.hours.ago)

      @incomplete_recent = @user.auth_factors.build(
        channel: 'sms',
        registration_complete: false
      )
      @incomplete_recent.save!(validate: false)
      @incomplete_recent.update_column(:created_at, 30.minutes.ago)
    end

    it 'should destroy incomplete registrations older than 1 hour via user scope' do
      assert_difference 'AuthFactor.count', -1 do
        @user.auth_factors
             .where(registration_complete: false)
             .where('created_at < ?', 1.hour.ago)
             .destroy_all
      end
      assert_raises(ActiveRecord::RecordNotFound) { @incomplete_old.reload }
    end

    it 'should not destroy recent incomplete registrations' do
      @user.auth_factors
           .where(registration_complete: false)
           .where('created_at < ?', 1.hour.ago)
           .destroy_all
      assert_nothing_raised { @incomplete_recent.reload }
    end

    it 'should not destroy completed registrations regardless of age' do
      assert_no_difference 'AuthFactor.where(registration_complete: true).count' do
        @user.auth_factors
             .where(registration_complete: false)
             .where('created_at < ?', 1.hour.ago)
             .destroy_all
      end
    end

    it 'should handle no incomplete registrations gracefully' do
      AuthFactor.where(registration_complete: false).destroy_all
      assert_nothing_raised do
        @user.auth_factors
             .where(registration_complete: false)
             .where('created_at < ?', 1.hour.ago)
             .destroy_all
      end
    end

    it 'should not affect incomplete registrations of other users' do
      other_user = create :user
      other_incomplete = other_user.auth_factors.build(
        channel: 'sms',
        registration_complete: false
      )
      other_incomplete.save!(validate: false)
      other_incomplete.update_column(:created_at, 2.hours.ago)

      @user.auth_factors
           .where(registration_complete: false)
           .where('created_at < ?', 1.hour.ago)
           .destroy_all

      assert_nothing_raised { other_incomplete.reload }
    end

    it 'should preserve completed factor for same user when cleaning incomplete' do
      completed_count = @user.auth_factors.where(registration_complete: true).count
      @user.auth_factors
           .where(registration_complete: false)
           .where('created_at < ?', 1.hour.ago)
           .destroy_all
      assert_equal completed_count, @user.auth_factors.where(registration_complete: true).count
    end
  end
end
