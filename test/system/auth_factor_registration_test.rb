require 'application_system_test_case'

class AuthFactorRegistrationTest < ApplicationSystemTestCase
  NICKNAME = 'my new factor'
  PHONE = '5555555555'
  CORRECT_CODE = '123456'
  INCORRECT_CODE = '000000'

  before do
    @twilio_verify_mock = Minitest::Mock.new

    create :line
    log_in_as create(:user)
  end

  describe 'registration step' do
    before do
      complete_up_to_registration_step
    end

    it 'should go to verification step when completed successfully' do
      @twilio_verify_mock.expect(:send_sms_verification_code, 'success', [PHONE])

      fill_in t('multi_factor.registration.name_label'), with: NICKNAME
      fill_in t('multi_factor.registration.phone_label'), with: PHONE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button t('multi_factor.next')
      end

      assert_text 'Verify SMS Authentication Factor'
    end

    it 'should not proceed if name empty' do
      fill_in t('multi_factor.registration.name_label'), with: ''
      fill_in t('multi_factor.registration.phone_label'), with: PHONE

      click_button t('multi_factor.next')

      assert_text "can't be blank"
      assert_text t('multi_factor.registration.heading')
    end

    it 'should not proceed if phone empty' do
      fill_in t('multi_factor.registration.name_label'), with: NICKNAME
      fill_in t('multi_factor.registration.phone_label'), with: ''

      click_button t('multi_factor.next')

      assert_text "can't be blank"
      assert_text t('multi_factor.registration.heading')
    end

    it 'should not proceed if phone format invalid' do
      fill_in t('multi_factor.registration.name_label'), with: NICKNAME
      fill_in t('multi_factor.registration.phone_label'), with: '123'

      click_button t('multi_factor.next')

      assert_text 'is invalid'
      assert_text t('multi_factor.registration.heading')
    end

    it 'should not proceed if sending SMS fails' do
      raises_exception = -> { raise StandardError }
      @twilio_verify_mock.expect(:send_sms_verification_code, raises_exception)

      fill_in t('multi_factor.registration.name_label'), with: NICKNAME
      fill_in t('multi_factor.registration.phone_label'), with: PHONE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button t('multi_factor.next')
      end

      assert_text 'There was a problem sending the verification code'
      assert_text t('multi_factor.registration.heading')
    end
  end

  describe 'verification step' do
    before do
      complete_up_to_verification_step
    end

    it 'should go to confirmation step when completed successfully' do
      @twilio_verify_mock.expect(:check_sms_verification_code, 'approved', [PHONE, CORRECT_CODE])

      fill_in t('multi_factor.verification.code_label'), with: CORRECT_CODE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button t('multi_factor.next')
      end

      assert_text t('multi_factor.confirmation.message')
    end

    it 'should not proceed if verification code is invalid' do
      @twilio_verify_mock.expect(:check_sms_verification_code, 'pending', [PHONE, INCORRECT_CODE])

      fill_in t('multi_factor.verification.code_label'), with: INCORRECT_CODE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button t('multi_factor.next')
      end

      assert_text t('multi_factor.code_invalid')
      assert_text 'Verify SMS Authentication Factor'
    end

    it 'should not proceed if call to check code raises exception' do
      raises_exception = -> { raise StandardError }
      @twilio_verify_mock.expect(:check_sms_verification_code, raises_exception)

      fill_in t('multi_factor.verification.code_label'), with: INCORRECT_CODE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button t('multi_factor.next')
      end

      assert_text 'There was a problem checking the verification code'
      assert_text 'Verify SMS Authentication Factor'
    end
  end

  describe 'confirmation step' do
    before do
      complete_up_to_confirmation_step
    end

    it 'should navigate to user profile on clicking Next button' do
      click_button t('multi_factor.next')
      assert_text 'User panel'
    end
  end

  describe 'after completing the wizard' do
    before do
      complete_wizard
    end

    it 'should show newly registered auth factor in profile' do
      visit edit_user_registration_path
      assert_text NICKNAME
      assert_text t('multi_factor.factor_list.enabled')
    end

    # Ensures we're not still seeing data from the previous registration, e.g. if the auth_factor id
    # isn't getting cleared from the session after completing the registration.
    it 'should allow starting a new registration' do
      click_button t('multi_factor.factor_list.add_button')
      assert_text t('multi_factor.registration.heading')
      assert_no_text NICKNAME
      assert_no_text PHONE
    end
  end

  private

  def complete_up_to_registration_step
    visit edit_user_registration_path
      click_button t('multi_factor.factor_list.enable_button')
  end

  def complete_up_to_verification_step
    complete_up_to_registration_step

    @twilio_verify_mock.expect(:send_sms_verification_code, 'success', [PHONE])

    fill_in t('multi_factor.registration.name_label'), with: 'my new factor'
    fill_in t('multi_factor.registration.phone_label'), with: PHONE

    TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
      click_button t('multi_factor.next')
    end
  end

  def complete_up_to_confirmation_step
    complete_up_to_verification_step

    @twilio_verify_mock.expect(:check_sms_verification_code, 'approved', [PHONE, CORRECT_CODE])

    TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
      fill_in t('multi_factor.verification.code_label'), with: CORRECT_CODE
      click_button t('multi_factor.next')
    end
  end

  def complete_wizard
    complete_up_to_confirmation_step
    click_button t('multi_factor.next')
  end
end
