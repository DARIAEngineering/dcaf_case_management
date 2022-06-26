require 'test_helper'

class EventsHelperTest< ActionView::TestCase
  describe 'fontawesome_classes' do
    it 'should kit properly' do
      event = create :event, event_type: :pledged, pledge_amount: 100
      assert_equal 'far fa-thumbs-up', fontawesome_classes(event)

      event = create :event, event_type: :left_voicemail
      assert_equal 'fas fa-phone-alt', fontawesome_classes(event)
    end
  end

  describe 'entry_text' do
    it 'should render a text block - pledged' do
      event = create :event, event_type: :pledged, pledge_amount: 100
      expected = "#{event.created_at.display_time} -- #{event.cm_name} sent a " \
                 "$100 pledge for <a href=\"/patients/#{event.patient_id}/edit\">" \
                 "#{event.patient_name}</a> <a data-remote=\"true\" rel=\"nofollow\" " \
                 "data-method=\"patch\" href=\"/call_lists/add_patient/#{event.patient_id}\">" \
                 "(Add to call list)</a>"

      assert_equal expected, entry_text(event)
    end
  end
end
