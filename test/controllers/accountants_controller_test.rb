require 'test_helper'

class AccountantsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
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
        post accountant_search_path, params: { search: searcher }, xhr: :true
        assert_response :success
      end
    end
  end

  describe 'edit_fulfillment method' do
    before do
      get edit_fulfillment_path
    end

    it 'should return success' do
      assert_response :success
    end
  end
end
