require 'test_helper'

class PatientsControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    sign_in @user
  end

  describe 'create method' do 
    before do 
      @patient = attributes_for :patient
    end

    it 'should create and save a new patient' do 
      assert_difference 'Patient.count', 1 do 
        post :create, patient: @patient
      end
    end

    it 'should redirect to the root path afterwards' do 
      post :create, patient: @patient
      assert_redirected_to root_path
    end

    it 'should fail to save if name is blank' do 
      @patient[:name] = ''
      assert_no_difference 'Patient.count' do
        post :create, patient: @patient
      end
    end

    it 'should fail to save if primary phone is blank is blank' do 
      @patient[:primary_phone] = ''
      assert_no_difference 'Patient.count' do
        post :create, patient: @patient
      end
    end

    it 'should allow save if primary phone is blank is blank' do 
      @patient[:secondary_phone] = ''
      assert_difference 'Patient.count', 1 do
        post :create, patient: @patient
      end
    end
  end
end
