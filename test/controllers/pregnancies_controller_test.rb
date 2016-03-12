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

  it "should get index" do
    get :index
    assert_response :success
  end

  it 'should get edit' do
    get :edit, id: @pregnancy
    assert_response :success
  end 

  describe 'search method' do
    it 'should return on name, primary phone, and secondary phone' do
      ['Susie Everyteen', '123-456-7890', '333-444-5555'].each do |searcher|
        post :search, search: searcher, format: :js
        assert_response :success
      end
    end
  end

  describe 'update method' do 
    before do 
      @payload = {
        "patient"=>{"name"=>"Susie Everyteen 2", "id"=>@patient.id}, 
        "appointment_date"=>"2016-01-04", 
        "clinic"=>{"name"=>"", "id"=>@clinic.id}
      }

      patch :update, id: @pregnancy, pregnancy: @payload 
      @pregnancy.reload
    end


    it 'should return a redirect' do # for now
      assert_response :redirect
    end

    it 'should update pregnancy fields' do
      assert_equal @pregnancy.appointment_date, '2016-01-04'.to_date
    end

    it 'should update clinic fields' do 
      assert_equal @pregnancy.patient.name, 'Susie Everyteen 2'
    end

    it 'should update patient fields' do 
    end

    it 'should reject bad fields' do 
    end

    it 'should die if there are not dependent object ids' do 
    end

    it 'should redirect if record does not exist' do 
    end

    it 'should flash a confirmation that things worked' do 
    end
  end
end
