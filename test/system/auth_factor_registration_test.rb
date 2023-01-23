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

      fill_in 'Nickname', with: NICKNAME
      fill_in 'Phone', with: PHONE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button 'Next'
      end

      assert_text 'Verify New SMS Authentication Factor'
    end

    it 'should not proceed if name empty' do
      fill_in 'Nickname', with: ''
      fill_in 'Phone', with: PHONE

      click_button 'Next'

      assert_text "can't be blank"
      assert_text 'Register SMS Authentication Factor'
    end

    it 'should not proceed if phone empty' do
      fill_in 'Nickname', with: NICKNAME
      fill_in 'Phone', with: ''

      click_button 'Next'

      assert_text "can't be blank"
      assert_text 'Register SMS Authentication Factor'
    end

    it 'should not proceed if phone format invalid' do
      fill_in 'Nickname', with: NICKNAME
      fill_in 'Phone', with: '123'

      click_button 'Next'

      assert_text 'is invalid'
      assert_text 'Register SMS Authentication Factor'
    end

    it 'should not proceed if sending SMS fails' do
      raises_exception = -> { raise StandardError }
      @twilio_verify_mock.expect(:send_sms_verification_code, raises_exception)

      fill_in 'Nickname', with: NICKNAME
      fill_in 'Phone', with: PHONE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button 'Next'
      end

      assert_text 'There was a problem sending the verification code'
      assert_text 'Register SMS Authentication Factor'
    end
  end

  describe 'verification step' do
    before do
      complete_up_to_verification_step
    end

    it 'should go to confirmation step when completed successfully' do
      @twilio_verify_mock.expect(:check_sms_verification_code, 'approved', [PHONE, CORRECT_CODE])

      fill_in 'Verification Code', with: CORRECT_CODE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button 'Next'
      end

      assert_text 'New authentication factor successfully registered!'
    end

    it 'should not proceed if verification code is invalid' do
      @twilio_verify_mock.expect(:check_sms_verification_code, 'pending', [PHONE, INCORRECT_CODE])

      fill_in 'Verification Code', with: INCORRECT_CODE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button 'Next'
      end

      assert_text 'invalid code'
      assert_text 'Verify New SMS Authentication Factor'
    end

    it 'should not proceed if call to check code raises exception' do
      raises_exception = -> { raise StandardError }
      @twilio_verify_mock.expect(:check_sms_verification_code, raises_exception)

      fill_in 'Verification Code', with: INCORRECT_CODE

      TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
        click_button 'Next'
      end

      assert_text 'There was a problem checking the verification code'
      assert_text 'Verify New SMS Authentication Factor'
    end
  end

  describe 'confirmation step' do
    before do
      complete_up_to_confirmation_step
    end

    it 'should navigate to user profile on clicking Next button' do
      click_button 'Next'
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
      assert_text 'Enabled'
    end

    # Ensures we're not still seeing data from the previous registration, e.g. if the auth_factor id
    # isn't getting cleared from the session after completing the registration.
    it 'should allow starting a new registration' do
      click_button 'Add New Authentication Factor'
      assert_text 'Register SMS Authentication Factor'
      assert_no_text NICKNAME
      assert_no_text PHONE
    end
  end

  private

  def submit_with_stubbed_twilio_client; end

  def complete_up_to_registration_step
    visit edit_user_registration_path
    click_button 'Enable Two Factor Authentication'
  end

  def complete_up_to_verification_step
    complete_up_to_registration_step

    @twilio_verify_mock.expect(:send_sms_verification_code, 'success', [PHONE])

    fill_in 'Nickname', with: 'my new factor'
    fill_in 'Phone', with: PHONE

    TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
      click_button 'Next'
    end
  end

  def complete_up_to_confirmation_step
    complete_up_to_verification_step

    @twilio_verify_mock.expect(:check_sms_verification_code, 'approved', [PHONE, CORRECT_CODE])

    TwilioVerifyClient.stub(:new, @twilio_verify_mock) do
      fill_in 'Verification Code', with: CORRECT_CODE
      click_button 'Next'
    end
  end

  def complete_wizard
    complete_up_to_confirmation_step
    click_button 'Next'
  end
end
