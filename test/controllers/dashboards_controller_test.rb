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
