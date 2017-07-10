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

  describe 'report method' do
    it 'should return success on proper timeframe' do
      get patients_report_path(timeframe: 'weekly')
      assert_response :success
      get patients_report_path(timeframe: 'monthly')
      assert_response :success
      get patients_report_path(timeframe: 'yearly')
      assert_response :success
    end

    it 'should return 406 on bad timeframe' do
      get patients_report_path(timeframe: 'nonexistent')
      assert_response 406
    end
  end

end
