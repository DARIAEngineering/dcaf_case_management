require 'application_system_test_case'

class UpdateUserInfoTest < ApplicationSystemTestCase
  extend Minitest::OptionalRetry

  before do
    create :line
    @user = create :user
    log_in_as @user
  end

  describe 'alter user info' do
    before do
      visit edit_user_registration_path
    end

    it 'should let you change name' do
      fill_in 'First and last name', with: 'Thorny'
      fill_in 'Current password', with: @user.password
      click_button 'Update info'
      assert has_text? 'Thorny'
    end

    it 'should not let you change email' do
      assert has_text? 'Email'
      assert_not has_field? 'Email'
    end

    it 'should veto changes without current password' do
      fill_in 'First and last name', with: 'Bad Name'
      click_button 'Update info'
      assert_text "Current password can't be blank"
      fill_in 'Current password', with: 'not_a_real_pAssw0rd'
      click_button 'Update info'
      assert_text 'Current password is invalid'
      assert_no_text 'Bad Name'
    end
  end

  describe 'Multi Factor Authentication' do
    before do
      @user.auth_factors.create attributes_for(:auth_factor, :not_enabled)
      @disabled_factor = @user.auth_factors.first
    end

    describe 'when no auth factors enabled' do
      before do
        visit edit_user_registration_path
      end

      it 'should display Enable Multi Factor Authentication' do
        assert_text t('multi_factor.factor_list.enable_button')
      end

      it 'should go to registration when Enable 2FA pressed' do
        click_button t('multi_factor.factor_list.enable_button')
        assert_text t('multi_factor.registration.heading')
      end
    end

    # describe 'when at least one auth factor enabled' do
    #   before do
    #     @user.auth_factors.create attributes_for(:auth_factor, :registration_complete)
    #     @enabled_factor = @user.auth_factors.last
    #     visit edit_user_registration_path
    #   end

    #   it 'should display Add New Authentication Factor' do
    #     assert_text t('multi_factor.factor_list.add_button')
    #   end

    #   it 'should display enabled factors' do
    #     assert_text @enabled_factor.name
    #     assert_no_text @disabled_factor.name
    #   end

    #   it 'should delete factor when delete button pressed' do
    #     click_button t('multi_factor.factor_list.delete_button')
    #     assert_no_text @enabled_factor.name
    #   end
    # end
  end
end
