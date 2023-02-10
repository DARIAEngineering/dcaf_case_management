require 'application_system_test_case'

class MfaLoginTest < ApplicationSystemTestCase
  PHONE = '5555555555'
  CORRECT_CODE = '123456'
  INCORRECT_CODE = '000000'

  before do
    @twilio_verify_mock = Minitest::Mock.new

    create :line
    @user = create :user
  end

  describe 'login' do
    it 'should successfully login user with no enabled auth factors' do
      @user.auth_factors.create attributes_for(:auth_factor, :not_enabled)
      log_in_as @user
      assert_text t('dashboard.search.header')
    end

    it 'should redirect user with an enabled auth factor MFA login' do
      @user.auth_factors.create attributes_for(:auth_factor, :registration_complete)
      log_in_as @user

      assert_text t('multi_factor.factor_select.heading')
    end
  end

  describe 'factor_select step' do
    before do
      @auth_factor_enabled = @user.auth_factors.create attributes_for(:auth_factor, :registration_complete)
      @auth_factor_disabled = @user.auth_factors.create attributes_for(:auth_factor, :not_enabled)
      log_in_as @user
    end

    it 'should include enabled auth factors as options' do
      assert_text @auth_factor_enabled.name
      assert_no_text @auth_factor_disabled.name
    end

    it 'should go to verification step when completed successfully' do
      @twilio_verify_mock.expect(:send_sms_verification_code, 'success', [PHONE])

      select @auth_factor_enabled.name, from: 'Auth factor'

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button t('multi_factor.next')
      end

      assert_text 'Verify SMS Authentication Factor'
    end

    it 'should not proceed if sending SMS fails' do
      raises_exception = -> { raise StandardError }
      @twilio_verify_mock.expect(:send_sms_verification_code, raises_exception)

      select @auth_factor_enabled.name, from: 'Auth factor'

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button t('multi_factor.next')
      end

      assert_text 'There was a problem sending the verification code'
      assert_text t('multi_factor.factor_select.heading')
    end
  end

  describe 'verification step' do
    before do
      complete_up_to_verification_step
    end

    it 'should log user in when code is correct' do
      @twilio_verify_mock.expect(:check_sms_verification_code, 'approved', [PHONE, CORRECT_CODE])

      fill_in t('multi_factor.verification.code_label'), with: CORRECT_CODE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button t('multi_factor.authenticate')
      end

      assert_text t('multi_factor.login_successful')
    end

    it 'should not proceed if verification code is invalid' do
      @twilio_verify_mock.expect(:check_sms_verification_code, 'pending', [PHONE, INCORRECT_CODE])

      fill_in t('multi_factor.verification.code_label'), with: INCORRECT_CODE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button t('multi_factor.authenticate')
      end

      assert_text t('multi_factor.code_invalid')
      assert_text 'Verify SMS Authentication Factor'
    end

    it 'should not proceed if call to check code raises exception' do
      raises_exception = -> { raise StandardError }
      @twilio_verify_mock.expect(:check_sms_verification_code, raises_exception)

      fill_in t('multi_factor.verification.code_label'), with: INCORRECT_CODE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button t('multi_factor.authenticate')
      end

      assert_text 'There was a problem checking the verification code'
      assert_text 'Verify SMS Authentication Factor'
    end
  end

  private

  def complete_up_to_verification_step
    auth_factor = @user.auth_factors.create attributes_for(:auth_factor, :registration_complete)
    log_in_as @user

    @twilio_verify_mock.expect(:send_sms_verification_code, 'success', [PHONE])

    select auth_factor.name, from: 'Auth factor'

    TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
      click_button t('multi_factor.next')
    end
  end
end
