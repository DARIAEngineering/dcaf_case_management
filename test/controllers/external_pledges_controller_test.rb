require 'test_helper'

class ExternalPledgesControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient
  end

  describe 'create method' do
    before do
      @pledge = attributes_for :external_pledge
      post patient_external_pledges_path(@patient), params: { external_pledge: @pledge }, xhr: true
    end

    it 'should create and save a new pledge' do
      @pledge[:source] = 'diff'
      assert_difference 'Patient.find(@patient).external_pledges.count', 1 do
        post patient_external_pledges_path(@patient), params: { external_pledge: @pledge }, xhr: true
      end
    end

    it 'should respond bad_request if the pledge does not submit' do
      # submitting a duplicate pledge
      post patient_external_pledges_path(@patient), params: { external_pledge: @pledge }, xhr: true
      assert_response :bad_request
    end

    it 'should respond success if the pledge submits' do
      assert_response :success
    end

    it 'should log the creating user' do
      assert_equal Patient.find(@patient).external_pledges.last.created_by, @user
    end
  end

  describe 'update method' do
    before do

      @patient.external_pledges.create source: 'Baltimore Abortion Fund',
                                     amount: 100,
                                     created_by: @user
      @pledge = @patient.external_pledges.first
      #@pledge = create :external_pledge, patient: @patient
      @pledge_edits = { source: 'Edited Pledge' }
      patch patient_external_pledge_path(@patient, @pledge), params: { external_pledge: @pledge_edits }, xhr: true
      @pledge.reload
    end

    it 'should respond with success' do
      assert_response :success
    end

    it 'should update the source field' do
      assert_equal @pledge.source, 'Edited Pledge'
    end

    it 'should produce an audit trail' do
      assert_equal @pledge.history_tracks.count, 2
      @changes = @pledge.history_tracks.last
      assert_equal @changes.modified[:updated_by_id], @user.id
      assert_equal @changes.modified[:source], 'Edited Pledge'
    end

    it 'should refuse to save pledge type to blank' do
      [nil, ''].each do |bad_text|
        assert_no_difference 'Patient.find(@patient)
                                     .external_pledges.find(@pledge)
                                     .history_tracks.count' do
          @pledge_edits[:source] = bad_text
          patch patient_external_pledge_path(@patient, @pledge), params: { external_pledge: @pledge_edits }, xhr: true
          assert_response :bad_request
          @pledge.reload
          assert_equal @pledge.source, 'Edited Pledge'
        end
      end
    end
  end

  describe 'destroy' do
    before do
      @patient.external_pledges.create source: 'Baltimore Abortion Fund',
                                     amount: 100,
                                     created_by: @user
      @pledge = @patient.external_pledges.first
      #@pledge = create :external_pledge, patient: @patient
    end

    it 'should set a pledge to inactive' do
      delete patient_external_pledge_path(@patient, @pledge), xhr: true
      @pledge.reload
      refute @pledge.active?
    end
  end
end
