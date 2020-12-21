require 'test_helper'

class AccountantsControllerTest < ActionDispatch::IntegrationTest
  before do
    @patient = create :patient, clinic: @clinic,
                                appointment_date: 4.days.from_now,
                                fund_pledge: 50
  end

  describe 'permissioning' do
    describe 'index' do
      [:admin, :data_volunteer].each do |permission|
        it "should allow data vol or above - #{permission.to_s}" do
          user = create :user, role: permission
          sign_in user
          get accountants_path
          assert_response :success
        end
      end

      [:cm].each do |permission|
        it "should deny CM or below data access - #{permission}" do
          user = create :user, role: permission
          sign_in user
          get accountants_path
          assert_redirected_to root_url
        end
      end
    end

    describe 'edit' do
      [:admin, :data_volunteer].each do |permission|
        it "should allow data vol or above - #{permission.to_s}" do
          user = create :user, role: permission
          sign_in user
          get edit_accountant_path(@patient), xhr: true
          assert_response :success
        end
      end

      [:cm].each do |permission|
        it "should deny CM or below - #{permission}" do
          user = create :user, role: permission
          sign_in user
          get edit_accountant_path(@patient), xhr: true
          assert_response :unauthorized
        end
      end
    end

    describe 'search' do
      [:admin, :data_volunteer].each do |permission|
        it "should allow data vol or above - #{permission.to_s}" do
          user = create :user, role: permission
          sign_in user
          post accountant_search_path, params: { search: '' }, xhr: true
          assert_response :success
        end
      end

      [:cm].each do |permission|
        it "should deny CM or below data access - #{permission}" do
          user = create :user, role: permission
          sign_in user
          post accountant_search_path, params: { search: '' }, xhr: true
          assert_response :unauthorized
        end
      end

      it 'should account for edge cases around empty times' do
        create :patient, name: 'susan everyteen',
                         appointment_date: 4.days.from_now,
                         fund_pledge: 500,
                         pledge_sent: true,
                         pledge_sent_at: nil,
                         clinic: create(:clinic)
        create :patient, name: 'susan everyteen 2',
                         appointment_date: 4.days.from_now,
                         fund_pledge: 500,
                         pledge_sent: true,
                         pledge_sent_at: 4.days.from_now,
                         clinic: create(:clinic)
        user = create :user, role: :data_volunteer
        sign_in user
        post accountant_search_path, params: { search: 'susan' }, xhr: true
        assert_response :success
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
