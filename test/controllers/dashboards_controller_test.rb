require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase
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

  test "should get index" do
    get :index
    assert_response :success
  end

end
