require 'test_helper'

class ChangeLogHelperTest < ActionView::TestCase
  describe 'safe_join_fields convenience method' do
    before do
      with_versioning do
        patient = create :patient, referred_by: 'Clinic A'
        patient.update referred_by: 'Clinic B'
        @changeset = patient.versions.first
      end
    end

    it 'should work' do
      assert safe_join_fields(@changeset.shaped_changes).include? '<strong>Referred by:</strong> Clinic A -&gt; Clinic B'
    end

    it 'should not include PII fields in version tracking' do
      with_versioning do
        patient = create :patient, name: 'Old name'
        patient.update name: 'New name', city: 'Canada'
        # PII-only changes are ignored by PaperTrail, so no new version is created
        assert_equal 0, patient.versions.where(event: 'update').count
      end
    end
  end
end
