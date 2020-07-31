require 'test_helper'

class CallTest < ActiveSupport::TestCase
  before do
    @patient = create :patient
    @patient.calls.create! attributes_for(:call, status: 'Left voicemail')
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
  end

  describe 'relationships' do
    it 'should be linkable to a patient' do
      assert_equal @call.can_call, @patient
    end
  end

  describe 'attachments' do
    it 'should respond to paper trail methods' do
      assert @call.respond_to? :versions
      assert @call.respond_to? :created_by
      assert @call.respond_to? :created_by_id
    end
  end

  describe 'methods' do
    it 'should know if it is recent' do
      assert @call.recent?
      @call.updated_at = 9.hours.ago
      refute @call.recent?
    end

    it 'should know if it resulted in reached' do
      assert_not @call.reached?
      @call.update status: 'Reached patient'
      assert @call.reached?
    end
  end

  describe 'callbacks' do
    it 'should create an event after' do
      assert_difference 'Event.count', 1 do
        @patient.calls.create attributes_for(:call)
      end
      last_event = Event.last
      last_call = @patient.calls.last

      assert_equal last_call.status, last_event.event_type
      assert_equal @patient.name, last_event.patient_name
      assert_equal @patient.id.to_s, last_event.patient_id
      assert_equal @patient.line, last_event.line
    end
  end
end
