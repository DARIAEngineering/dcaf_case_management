require 'test_helper'

class CallTest < ActiveSupport::TestCase
  before do
    with_versioning do
      @user = create :user
      PaperTrail.request(whodunnit: @user) do
        @patient = create :patient
        @patient.calls.create attributes_for(:call)
      end
      @call = @patient.calls.first
    end
  end

  describe 'basic validations' do
    it 'should build' do
      assert @call.valid?
    end

    it 'should only allow certain statuses' do
      @call.status = nil
      refute @call.valid?

      valid_call_statuses =
        [:left_voicemail, :couldnt_reach_patient, :reached_patient]
      valid_call_statuses.each do |status|
        @call.status = status
        assert @call.valid?
      end
    end
  end

  describe 'relationships' do
    it 'should be linkable to a patient' do
      assert_equal @call.can_call, @patient
    end

    it 'should be linkable to a user' do
      assert_equal @call.created_by, @user
    end
  end

  describe 'concerns' do
    it 'should respond to history methods' do
      assert @call.respond_to? :versions
      assert @call.respond_to? :created_by
      assert @call.respond_to? :created_by_id
    end
  end
end
