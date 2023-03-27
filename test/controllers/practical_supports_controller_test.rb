require 'test_helper'

class PracticalSupportsControllerTest < ActionDispatch::IntegrationTest
  before do
    @patient = create :patient
    @user = create :user
    sign_in @user
  end

  describe 'create' do
    before do
      with_versioning(@user) do
        @support = attributes_for :practical_support
        post patient_practical_supports_path(@patient),
             params: { practical_support: @support },
             xhr: true
      end
    end

    it 'should create and save a new support record' do
      @support[:support_type] = 'different'
      assert_difference 'Patient.find(@patient.id).practical_supports.count', 1 do
        post patient_practical_supports_path(@patient), params: { practical_support: @support }, xhr: true
      end
    end

    it 'should respond bad_request if the support record does not save' do
      # submitting a support with an invalid source
      invalid_support = attributes_for :practical_support, source: Faker::Lorem.characters(number: 151)
      post patient_practical_supports_path(@patient), params: { practical_support: invalid_support }, xhr: true
      assert response.body.include? 'failed to save'
    end

    it 'should respond success if the support record saves' do
      assert response.body.include? 'saved'
    end

    it 'should log the creating user' do
      assert_equal Patient.find(@patient.id).practical_supports.last.created_by,
                   @user
    end
  end

  describe 'update' do
    before do
      @patient.practical_supports.create support_type: 'Transit',
                                         confirmed: false,
                                         source: 'Transit',
                                         amount: 10
      @support = @patient.practical_supports.first
      @support_edits = { support_type: 'Lodging' }
      patch patient_practical_support_path(@patient, @support),
            params: { practical_support: @support_edits },
            xhr: true
      @support.reload
    end

    it 'should respond success' do
      assert response.body.include? 'saved'
    end

    it 'should update the support_type field' do
      assert_equal @support.support_type, 'Lodging'
    end

    [:source, :support_type].each do |field|
      it "should refuse to save #{field} to blank" do
        [nil, ''].each do |bad_text|
          assert_no_difference '@support.versions.count' do
            @support_edits[:source] = bad_text
            patch patient_practical_support_path(@patient, @support),
                  params: { practical_support: @support_edits },
                  xhr: true
            assert response.body.include? 'failed to save'
          end
        end
      end
    end

    it 'should allow blank amount' do
      @support_edits[:amount] = nil
      patch patient_practical_support_path(@patient, @support),
            params: { practical_support: @support_edits },
            xhr: true
      assert response.body.include? 'saved'
    end

    it 'should not allow negative amounts' do
      @support_edits[:amount] = -3
      patch patient_practical_support_path(@patient, @support),
            params: { practical_support: @support_edits },
            xhr: true
      assert response.body.include? 'failed to save'
    end
  end

  describe 'destroy' do
    before do
      @patient.practical_supports.create support_type: 'Transit',
                                         confirmed: false,
                                         source: 'Transit'
      @support = @patient.practical_supports.first
    end

    it 'should destroy a support record' do
      assert_difference 'Patient.find(@patient.id).practical_supports.count', -1 do
        delete patient_practical_support_path(@patient, @support), xhr: true
      end
    end
  end
end
