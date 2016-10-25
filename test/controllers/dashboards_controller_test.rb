require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase
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

  describe 'search method' do
    it 'should return on name, primary phone, and other phone' do
      ['Susie Everyteen', '123-456-7890', '333-444-5555'].each do |searcher|
        post :search, search: searcher, format: :js
        assert_response :success
      end
    end
  end

  describe 'lineselect method' do
    before do
      get :lineselect
    end

    it 'should return success' do
      assert_response :success
    end
  end

end
