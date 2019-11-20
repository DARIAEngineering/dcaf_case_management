require 'test_helper'

class EventsHelperTest< ActionView::TestCase
  describe 'display_event' do
    it 'should render an event line - pledged' do
      event = create :event, event_type: 'Pledged', pledge_amount: 100
      expected = "<span class=\"far fa-thumbs-up event-item\" /> " \
                 "#{event.created_at.display_time} -- #{event.cm_name} sent a " \
                 "$100 pledge for <a href=\"/patients/#{event.patient_id}/edit\">" \
                 "#{event.patient_name}</a> <a data-remote=\"true\" rel=\"nofollow\" " \
                 "data-method=\"patch\" href=\"/call_lists/add_patient/#{event.patient_id}\">" \
                 "(Add to call list)</a>"

      assert_equal expected, display_event(event)
    end
  end
end
