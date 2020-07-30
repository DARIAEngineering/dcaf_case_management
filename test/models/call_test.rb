require 'test_helper'

class CallTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient
    @patient.calls.create attributes_for :call
    @call = @patient.calls.first
  end

  describe 'basic validations' do
    it 'should build' do
      assert @call.valid?
    end

    it 'should only allow certain statuses' do
      [nil, 'not a status'].each do |bad_status|
        @call.status = bad_status
        refute @call.valid?
      end
      valid_call_statuses =
        ['Left voicemail', "Couldn't reach patient", 'Reached patient']
      valid_call_statuses.each do |status|
        @call.status = status
        assert @call.valid?
      end
    end

    # it 'should require a user id' do
    #   @call.created_by = nil
    #   refute @call.valid?
    # end
  end

  describe 'relationships' do
    it 'should be linkable to a patient' do
      assert_equal @call.can_call, @patient
    end

    it 'should be linkable to a user' do
      assert_equal @call.created_by, @user
    end
  end

  describe 'pg attachments' do
    it 'should respond to history methods' do
      assert @call.respond_to? :versions
      assert @call.versions.count > 0
    end

    it 'should have accessible userstamp methods' do
      assert @call.respond_to? :created_by
      assert @call.created_by
    end
  end
end
