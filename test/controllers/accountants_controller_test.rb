require 'test_helper'

class AccountantsControllerTest < ActionDispatch::IntegrationTest
  before do
    @patient = create :patient, clinic: @clinic,
                                appointment_date: 4.days.from_now,
                                fund_pledge: 50
  end

  describe 'admin use only' do
    before do
      @nonadmin_user = create :user, role: :cm
      sign_in @nonadmin_user
    end

    describe 'get routes' do
      it 'should prevent nonadmins from using index' do
        get accountants_path
        assert_redirected_to root_path
      end

      it 'should prevent nonadmins from using edit' do
        get edit_accountant_path(@patient), xhr: true
        assert_redirected_to root_path
      end
    end

    describe 'post routes' do
      it 'should prevent nonadmins from using search' do
        post accountant_search_path, params: { search: '' }, xhr: true
        assert_response :unauthorized
      end
    end
  end

  describe 'endpoint behavior' do
    before do
      @user = create :user, role: :admin
      @clinic = create :clinic
      sign_in @user
    end

    describe 'index method' do
      before do
        get accountants_path
      end

      it 'should return success' do
        assert_response :success
      end
    end

    describe 'search method' do
      it 'should return on name, primary phone, and other phone' do
        ['Susie Everyteen', '123-456-7890', '333-444-5555'].each do |searcher|
          post accountant_search_path, params: { search: searcher }, xhr: true
          assert_response :success
        end
      end

      it 'should still work on an empty string' do
        post accountant_search_path, params: { search: '' }, xhr: true
        assert_response :success
      end
    end

    describe 'edit_fulfillment method' do
      before do
        get edit_accountant_path(@patient), xhr: true
      end

      it 'should return success' do
        assert_response :success
      end
    end
  end
end
