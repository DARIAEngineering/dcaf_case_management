require 'test_helper'

class PregnanciesControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      secondary_phone: '333-444-5555'
    @pregnancy = create :pregnancy, appointment_date: nil, patient: @patient
    @clinic = create :clinic, pregnancy: @pregnancy
  end

  describe 'edit method' do
    before do
      get :edit, id: @pregnancy
    end

    it 'should get edit' do
      assert_response :success
    end

    it 'should redirect to root on a bad id' do
      get :edit, id: 'notanid'
      assert_redirected_to root_path
    end
  end

  describe 'update method' do
    before do
      @payload = {
        patient: { name: 'Susie Everyteen 2', id: @patient.id },
        appointment_date: '2016-01-04',
        clinic: { name: 'Clinic A', id: @clinic.id}
      }

      patch :update, id: @pregnancy, pregnancy: @payload
      @pregnancy.reload
    end


    it 'should redirect on completion' do # for now
      assert_redirected_to edit_pregnancy_path(@pregnancy)
    end

    it 'should update pregnancy fields' do
      assert_equal @pregnancy.appointment_date, '2016-01-04'.to_date
    end

    it 'should update clinic fields' do
      assert_equal @pregnancy.clinic.name, 'Clinic A'
    end

    it 'should update patient fields' do
      assert_equal @pregnancy.patient.name, 'Susie Everyteen 2'
    end

    it 'should redirect if record does not exist' do
      patch :update, id: 'notanactualid', pregnancy: @payload
      assert_redirected_to root_path
    end
  end
end
