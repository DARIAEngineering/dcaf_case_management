require 'test_helper'

class LinesControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
    session[:line] = 'dc'
    @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      other_phone: '333-444-5555'
    @pregnancy = create :pregnancy, patient: @patient
  end

  describe 'new' do
    before do
      get :new
    end

    it 'should return success' do
      assert_response :success
    end
  end

  describe 'create' do
    before do
      post :create, line: 'MD'
    end

    it 'should set a session variable' do
      assert_equal 'MD', session[:line]
    end

    # TODO: Enforce line values
    # it 'should reject anything not set in lines' do
    # end
  end
end
