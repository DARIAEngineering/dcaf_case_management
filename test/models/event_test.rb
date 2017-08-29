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
    it 'should render the correct glyphicon' do
      assert_equal 'earphone', @event.glyphicon

      @event.event_type = 'Pledged'
      assert_equal 'usd', @event.glyphicon
    end

    it 'should do something on event text' do
      assert @event.event_text
    end
  end
end
