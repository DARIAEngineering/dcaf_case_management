require 'test_helper'

class PledgesControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient
  end

  describe 'create method' do
    before do
      @pledge = attributes_for :pledge
      post :create, patient_id: @patient.id, pledge: @pledge
    end

    it 'should create and save a new pledge' do
      assert_difference 'Patient.find(@patient).pledges.count', 1 do
        post :create, patient_id: @patient.id, pledge: @pledge
      end
    end

    # NOTE: it's redirecting so status code 302
    #   it 'should respond success if the pledge submits' do
    #     assert_response :success
    #   end

    # NOTE: template does not exist yet	and controller redirects
    #   it 'should render create.js.erb if it successfully saves' do
    #     assert_template 'pledges/create'
    #   end

    it 'should redirect to edit patient path if it saves' do
      assert_redirected_to edit_patient_path(@patient)
    end

    it 'should log the creating user' do
      assert_equal Patient.find(@patient).pledges.last.created_by, @user
    end
  end

  describe 'update method' do
    before do
      @pledge = create :pledge, patient: @patient,
                                pledge_type: 'Original Pledge'
      @pledge_edits = { pledge_type: 'Edited Pledge' }
      patch :update, patient_id: @patient, id: @pledge,
                     pledge: @pledge_edits, format: :js
      @pledge.reload
    end

    it 'should render the correct template' do
      assert_template 'pledges/update'
    end

    it 'should respond with success' do
      assert_response :success
    end

    it 'should update the pledge_type field' do
      assert_equal @pledge.pledge_type, 'Edited Pledge'
    end

    it 'should have an audit trail' do
      assert_equal @pledge.history_tracks.count, 2
      @changes = @pledge.history_tracks.last
      assert_equal @changes.modified[:updated_by_id], @user.id
      assert_equal @changes.modified[:pledge_type], 'Edited Pledge'
    end

    it 'should refuse to save pledge type to blank' do
      [nil, ''].each do |bad_text|
        assert_no_difference 'Patient.find(@patient)
                                     .pledges.find(@pledge)
                                     .history_tracks.count' do
          @pledge_edits[:pledge_type] = bad_text
          patch :update, patient_id: @patient, id: @pledge,
                         pledge: @pledge_edits, format: :js
          assert_response :bad_request
          @pledge.reload
          assert_equal @pledge.pledge_type, 'Edited Pledge'
        end
      end
    end
  end
end
