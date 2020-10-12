require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Since this is a devise install, devise is handling
  # general stuff like creation timestamps etc.

  before do
    @user = create :user
  end

  describe 'basic validations' do
    it 'should be able to build an object' do
      assert @user.valid?
    end

    %w(email name).each do |attribute|
      it "should require content in #{attribute}" do
        @user[attribute.to_sym] = nil
        assert_not @user.valid?
        assert_equal "can't be blank",
                     @user.errors.messages[attribute.to_sym].first
      end
    end

    it 'should require a complex password' do
      @user.password = 'password'
      @user.password_confirmation = 'password'
      assert_not @user.valid?
      assert_equal 'Password must include at least one lowercase letter, ' \
                   'one uppercase letter, and one digit. Forbidden words ' \
                   'include DCAF and password.',
                   @user.errors.messages[:password].first
    end
    
    it 'should require a complex password' do
      @user.password = 'Hello#2020'
      @user.password_confirmation = 'Hello#2020'
      assert_not @user.valid?
      assert_equal 'Passwords need to be stronger than that. ' \
                   'Try a longer or more complicated password please',
                   @user.errors.messages[:password].first
    end
  end
  
  describe 'call list methods' do
    before do
      @patient = create :patient, line: 'DC'
      @patient_2 = create :patient, line: 'DC'
      @md_patient = create :patient, line: 'MD'
      @user.patients << @patient
      @user.patients << @patient_2
      @user.patients << @md_patient
      @user_2 = create :user
    end

    it 'should return recently_called_patients accurately' do
      assert_equal 0, @user.recently_called_patients('DC').count

      @patient.calls.create attributes_for(:call, created_by: @user)
      @patient_2.calls.create attributes_for(:call, created_by: @user)
      @md_patient.calls.create attributes_for(:call, created_by: @user)
      assert_equal 2, @user.recently_called_patients('DC').count
      assert_equal 1, @user.recently_called_patients('MD').count
    end

    it 'should return call_list_patients accurately' do
      assert_equal 2, @user.call_list_patients('DC').count
      assert_equal 1, @user.call_list_patients('MD').count

      @patient.calls.create attributes_for(:call, created_by: @user)
      assert_equal 1, @user.call_list_patients('DC').count

      @patient_2.calls.create attributes_for(:call, created_by: @user_2)
      assert_equal 1, @user.call_list_patients('DC').count
    end

    it 'should clean calls when patient has been reached' do
      assert_equal 0, @user.recently_called_patients('DC').count
      @patient.calls.create attributes_for(:call, created_by: @user, status: 'Reached patient')
      @call = @patient.calls.first
      assert_equal 1, @user.recently_called_patients('DC').count
      @user.clean_call_list_between_shifts
      assert_equal 0, @user.recently_called_patients('DC').count
    end

    it 'should not clear calls when patient has not been reached' do
      assert_equal 0, @user.recently_called_patients('DC').count
      @patient.calls.create attributes_for(:call, created_by: @user, status: 'Left voicemail' )
      @call = @patient.calls.first
      assert_equal 1, @user.recently_called_patients('DC').count
      @user.clean_call_list_between_shifts
      assert_equal 1, @user.recently_called_patients('DC').count
    end

    it 'should clear patient list when user has not logged in' do
      assert_not @user.patients.empty?
      last_sign_in = Time.zone.now - User::TIME_BEFORE_INACTIVE - 1.day
      @user.current_sign_in_at = last_sign_in
      @user.clean_call_list_between_shifts

      assert @user.patients.empty?
    end

    it 'should not clear patient list if user signed in recently' do
      assert_not @user.patients.empty?
      @user.current_sign_in_at = Time.zone.now
      @user.clean_call_list_between_shifts

      assert_not @user.patients.empty?
    end

    it 'should clear call list when someone invokes the cleanout' do
      assert_difference '@user.patients.count', -3 do
        assert_no_difference 'Patient.count' do
          @user.clear_call_list
        end
      end
    end
  end

  describe 'patient methods' do
    before do
      @patient = create :patient, line: 'MD'
      @patient_2 = create :patient
      @patient_3 = create :patient
    end

    it 'add patient - should add a patient to a set' do
      assert_difference '@user.patients.count', 1 do
        @user.add_patient @patient
      end
    end

    it 'remove patient - should remove a patient from a set' do
      @user.add_patient @patient
      assert_difference '@user.patients.count', -1 do
        @user.remove_patient @patient
      end
    end

    describe 'reorder call list' do
      before do
        set_of_patients = [@patient, @patient_2, @patient_3]
        set_of_patients.each { |preg| @user.add_patient preg }
        @new_order = [@patient_3.id.to_s, @patient.id.to_s, @patient_2.id.to_s]
        @user.reorder_call_list @new_order
      end

      it 'should let you reorder a call list' do
        assert_equal @patient_3, @user.ordered_patients('DC').first
        assert_equal @patient_2, @user.ordered_patients('DC')[1]
      end

      it 'should always add new patients to the front of the call order' do
        @patient_4 = create :patient
        @user.add_patient @patient_4

        assert @user.ordered_patients('DC').include? @patient_4
        assert @user.call_order.index(@patient_4.id.to_s) == 0
      end
    end
  end

  describe 'relationships' do
    before do
      @patient = create :patient
      @patient_2 = create :patient
      @user.patients << @patient
      @user.patients << @patient_2
      @user_2 = create :user
    end

    it 'should have any belong to many patients' do
      [@patient, @patient_2].each do |preg|
        [@user, @user_2].each { |user| user.add_patient preg }
      end

      assert_equal @user.patients, @user_2.patients
    end
  end

  describe 'omniauthing' do
    before do
      @token = OpenStruct.new info: { 'email' => @user.email }
    end

    it 'should return a user from an access token' do
      assert_equal @user, User.from_omniauth(@token)
    end

    it 'should error on no user' do
      @user.destroy
      assert_raises Mongoid::Errors::DocumentNotFound do
        User.from_omniauth(@token)
      end
    end
  end

  describe 'data access' do
    it 'should allow for admins' do
      assert create(:user, role: :admin).allowed_data_access?
    end

    it 'should allow for data volunteers' do
      assert create(:user, role: :data_volunteer).allowed_data_access?
    end

    it 'should not allow for CMs' do
      refute create(:user, role: :cm).allowed_data_access?
    end
  end

  describe 'manual account shutoff (disabled_by_fund)' do
    before { @user = create :user }
    it 'should default to enabled' do
      refute @user.disabled_by_fund?
    end

    it 'is toggleable' do
      @user.toggle_disabled_by_fund
      @user.reload
      assert @user.disabled_by_fund
    end

    describe 'nightly cleanup task - disable_inactive_users' do
      before do
        @disabled_user = create(:user, current_sign_in_at: 10.months.ago)
        @admin = create(:user, role: :admin, current_sign_in_at: 11.months.ago)
        @no_login_user = create(:user, created_at: 12.months.ago)
        @nondisabled_user = create(:user, current_sign_in_at: 8.months.ago)
        User.disable_inactive_users
      end

      it 'should find inactive users with logins before cutoff and disable' do
        [@disabled_user, @no_login_user].each do |user|
          user.reload
          assert user.disabled_by_fund?
        end

        # No locking admins or users with recent activity
        [@admin, @nondisabled_user].each do |user|
          user.reload
          assert_not user.disabled_by_fund?
        end
      end
    end
  end
end
