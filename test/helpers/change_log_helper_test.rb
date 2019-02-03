require 'test_helper'

class ChangeLogHelperTest < ActionView::TestCase
  describe 'safe_join_fields convenience method' do
    before do
      pt = create :patient, name: 'Old name'
      pt.update name: 'New name', city: 'Canada'
      @changeset = pt.history_tracks.last
    end

    it 'should work' do
      assert_equal safe_join_fields(@changeset.shaped_changes),
                   '<strong>Name:</strong> Old name -&gt; New name<br />' \
                   '<strong>City:</strong> (empty) -&gt; Canada'
    end
  end
end
