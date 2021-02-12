require 'test_helper'

class EventTest < ActiveSupport::TestCase
  before { @event = create :event }

  describe 'basic validations' do
    it 'should build' do
      assert @event.valid?
    end

    it 'should only allow certain statuses' do
      assert_raises ArgumentError do
        @event.event_type = :notatype
        @event.valid?
      end

      [
        :reached_patient, :couldnt_reach_patient,
        :left_voicemail, :unknown_action
      ].each do |status|
        @event.event_type = status
        assert @event.valid?
      end
      @event.update event_type: :pledged, pledge_amount: 100
      assert @event.valid?
    end

    it 'should only allow certain lines' do
      assert_raises ArgumentError do
        @event.line = :notaline
        @event.valid?
      end
    end

    [:patient_name, :patient_id, :cm_name, :event_type].each do |req_field|
      it "requires #{req_field}" do
        @event[req_field] = nil
        refute @event.valid?
      end
    end

    it 'requires a pledge amount if pledged type' do
      @event.event_type = :pledged
      refute @event.valid?
      @event.pledge_amount = 100
      assert @event.valid?
    end
  end

  describe 'rendering methods' do
    describe 'icon' do
      it 'should render the correct icon' do
        assert_equal 'phone-alt', build(:event, event_type: :couldnt_reach_patient).icon
        assert_equal 'comment', build(:event, event_type: :reached_patient).icon
        assert_equal 'thumbs-up', build(:event, event_type: :pledged).icon
        assert_equal 'phone-alt', build(:event, event_type: :left_voicemail).icon
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
