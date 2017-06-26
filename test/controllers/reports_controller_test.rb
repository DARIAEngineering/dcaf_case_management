require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      other_phone: '333-444-5555'
  end

  describe 'index method' do
    before do
      get reports_path
    end

    it 'should return success' do
      assert_response :success
    end
  end

  describe 'weekly_report method' do
    before do
      get weekly_report_path
    end

    it 'should return success' do
      assert_response :success
    end
  end

  describe 'monthly_report method' do
    before do
      get monthly_report_path
    end

    it 'should return success' do
      assert_response :success
    end
  end

  describe 'yearly_report method' do
    before do
      get yearly_report_path
    end

    it 'should return success' do
      assert_response :success
    end
  end
end
