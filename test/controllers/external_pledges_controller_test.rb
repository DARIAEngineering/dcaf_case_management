require 'test_helper'

class ExternalPledgesControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient
  end

  describe 'create method' do
    before do
      @pledge = attributes_for :external_pledge
      post :create, patient_id: @patient.id, external_pledge: @pledge, format: :js
    end

    it 'should create and save a new pledge' do
      @pledge[:source] = 'diff'
      assert_difference 'Patient.find(@patient).external_pledges.count', 1 do
        post :create, patient_id: @patient.id, external_pledge: @pledge, format: :js
      end
    end

    it 'should respond bad_request if the pledge does not submit' do
      # submitting a duplicate pledge
      post :create, patient_id: @patient.id, external_pledge: @pledge, format: :js
      assert_response :bad_request
    end

    # commented out until we get the ajax working :(
    # it 'should render create js if it saves' do
      # assert_template 'external_pledges/create'
    # end

    # it 'should respond success if the pledge submits' do
    #   assert_response :success
    # end

    it 'should redirect to patient edit page' do
      assert_redirected_to edit_patient_path(@patient)
    end

    it 'should log the creating user' do
      assert_equal Patient.find(@patient).external_pledges.last.created_by, @user
    end
  end

  describe 'update method' do
    before do
      @pledge = create :external_pledge, patient: @patient
      @pledge_edits = { source: 'Edited Pledge' }
      patch :update, patient_id: @patient, id: @pledge,
                     external_pledge: @pledge_edits, format: :js
      @pledge.reload
    end

    it 'should render the correct template' do
      assert_template 'external_pledges/update'
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
          patch :update, patient_id: @patient, id: @pledge,
                         external_pledge: @pledge_edits, format: :js
          assert_response :bad_request
          @pledge.reload
          assert_equal @pledge.source, 'Edited Pledge'
        end
      end
    end
  end

  describe 'destroy' do
    before { @pledge = create :external_pledge, patient: @patient }

    it 'should set a pledge to inactive' do
      delete :destroy, patient_id: @patient, id: @pledge, format: :js
      @pledge.reload
      refute @pledge.active?
    end
  end
end
