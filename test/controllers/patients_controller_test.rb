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
    end

    it 'should require a name and primary phone number' do 
      @patient[:name] = nil 
      assert_no_difference 'Patient.count' do 
        post :create, patient: @patient
      end
    end
  end
end
