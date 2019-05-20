require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  describe 'endpoints' do
    before do
      @data_volunteer = create :user, role: :data_volunteer
      sign_in @data_volunteer
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
        get patients_report_path(timeframe: 'weekly'), xhr: true
        assert_response :success
        get patients_report_path(timeframe: 'monthly'), xhr: true
        assert_response :success
        get patients_report_path(timeframe: 'yearly'), xhr: true
        assert_response :success
      end

      it 'should return not_acceptable on bad timeframe' do
        get patients_report_path(timeframe: 'nonexistent'), xhr: true
        assert_response 406
      end
    end
  end

  describe 'permissioning' do
    describe 'index' do
      [:admin, :data_volunteer].each do |permission|
        it "should allow data vol or above - #{permission.to_s}" do
          user = create :user, role: permission
          sign_in user
          get reports_path
          assert_response :success
        end
      end

      [:cm].each do |permission|
        it "should deny CM or below data access - #{permission}" do
          user = create :user, role: permission
          sign_in user
          get reports_path
          assert_redirected_to root_url
        end
      end
    end

    describe 'report' do
      [:admin, :data_volunteer].each do |permission|
        it "should allow data vol or above - #{permission.to_s}" do
          user = create :user, role: permission
          sign_in user
          get patients_report_path(timeframe: 'weekly'), xhr: true
          assert_response :success
        end
      end

      [:cm].each do |permission|
        it "should deny CM or below data access - #{permission}" do
          user = create :user, role: permission
          sign_in user
          get patients_report_path(timeframe: 'weekly'), xhr: true
          assert_response :unauthorized
        end
      end
    end
  end
end
