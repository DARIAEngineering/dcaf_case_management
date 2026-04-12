require 'test_helper'

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @line = create :line
    @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      other_phone: '333-444-5555',
                      line: @line
    sign_in @user
    choose_line @line
  end

  describe 'index method' do
    before do
      get dashboard_path
    end

    it 'should return success' do
      assert_response :success
    end
  end

  describe 'follow-up patients on dashboard' do
    before do
      @follow_up_patient = create :patient,
                                  name: 'Follow Up Needed',
                                  line: @line,
                                  follow_up_date: 1.day.ago.to_date,
                                  follow_up_reason: 'Check insurance status'
    end

    it 'should include follow-up patients in the dashboard' do
      get dashboard_path
      assert_response :success
      assert_match(/Follow Up Needed/, response.body)
    end

    it 'should not include patients without a follow-up date' do
      get dashboard_path
      assert_response :success
      assert_no_match(/Susie Everyteen/, response.body.scan(/follow-ups-due.*?<\/div>/m).join)
    end

    it 'should not include patients with future follow-up dates' do
      @follow_up_patient.update! follow_up_date: 3.days.from_now.to_date
      get dashboard_path
      assert_response :success
      assert_no_match(/Follow Up Needed/, response.body.scan(/follow-ups-due.*?<\/div>/m).join)
    end
  end

  describe 'search method' do
    it 'should return on name, primary phone, and other phone' do
      ['Susie Everyteen', '123-456-7890', '333-444-5555'].each do |searcher|
        post search_path, params: { search: searcher }, xhr: true
        assert_response :success
      end
    end
  end

  describe 'budget bar method' do
    it 'should return success' do
      get budget_bar_path, xhr: true
      assert_response :success
    end

    describe 'budget bar calculations' do
      it 'handles the empty case' do
        assert_equal DashboardsController.new.budget_bar_calculations(@line),
                     { limit: 1_000, expenditures: { sent: [], pledged: [] } }
      end

      it 'calculates if information is set' do
        create :clinic
        @patient.update appointment_date: 3.days.from_now,
                        clinic_id: Clinic.first.id,
                        fund_pledge: 50

        assert_equal DashboardsController.new.budget_bar_calculations(@line),
                     { limit: 1_000, expenditures: Patient.pledged_status_summary(@line) }
      end
    end
  end
end
