require 'test_helper'

class EventTest < ActiveSupport::TestCase
  before { @event = create :event }

  describe 'basic validations' do
    it 'should build' do
      assert @event.valid?
    end

    it 'should only allow certain statuses' do
      [nil, 'not a status'].each do |bad_status|
        @event.event_type = bad_status
        refute @event.valid?
      end

      valid_types = ['Reached patient', "Couldn't reach patient",
                     'Left voicemail']
      valid_types.each do |status|
        @event.event_type = status
        assert @event.valid?
      end
    end

    [:patient_name, :patient_id, :cm_name].each do |req_field|
      it "requires #{req_field}" do
        @event[req_field] = nil
        refute @event.valid?
      end
    end

    it 'requires a pledge amount if pledged type' do
      @event.event_type = 'Pledged'
      refute @event.valid?
      @event.pledge_amount = 100
      assert @event.valid?
    end
  end

  describe 'rendering methods' do
    describe 'icon' do
      it 'should render the correct icon' do
        @event.event_type = "Couldn't reach patient"
        assert_equal 'phone-alt', @event.icon

        @event.event_type = 'Reached patient'
        assert_equal 'comment', @event.icon

        @event.event_type = 'Pledged'
        assert_equal 'thumbs-up', @event.icon

        @event.event_type = 'Left voicemail'
        assert_equal 'phone-alt', @event.icon
      end
    end

    describe 'underscored_type' do
      it 'should translate to type without punctuation, with underscores' do
        assert_equal 'pledged', create(:event, event_type: 'Pledged', pledge_amount: 100).underscored_type
        assert_equal 'left_voicemail', create(:event, event_type: 'Left voicemail').underscored_type
        assert_equal 'reached_patient', create(:event, event_type: 'Reached patient').underscored_type
      end
    end
  end

  describe 'cleaning old events' do
    before do
      # Here are the destroyers
      create :event, created_at: 4.weeks.ago
      create :event, created_at: 22.days.ago
      create :event, created_at: 3.weeks.ago

      # Here are the keepers
      # In addition to the other event...
      create :event, created_at: 20.days.ago
      create :event, created_at: 2.weeks.ago
    end

    it 'should be able to clean old events' do
      assert_equal 6, Event.count
      Event.destroy_old_events

      assert_equal 3, Event.count
    end
  end
end
