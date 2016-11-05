require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      other_phone: '333-444-5555'
    @pregnancy = create :pregnancy, patient: @patient
  end

  describe 'index method' do
    before do
      get :index
    end

    it 'should return success' do
      assert_response :success
    end
  end
end
