require 'test_helper'

class ChangeLogHelperTest < ActionView::TestCase
  describe 'safe_join_fields convenience method' do
    before do
      with_versioning do
        patient = create :patient, name: 'Old name'
        patient.update name: 'New name', city: 'Canada'
        @changeset = patient.versions.first
      end
    end

    it 'should work' do
      assert safe_join_fields(@changeset.shaped_changes).include? "<strong>Name:</strong> Old name -&gt; New name"
      assert safe_join_fields(@changeset.shaped_changes).include? '<strong>City:</strong> (empty) -&gt; Canada'
    end
  end
end
