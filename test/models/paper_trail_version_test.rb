require 'test_helper'

class PaperTrailVersionTest < ActiveSupport::TestCase
  before do
    @user = create :user
    with_versioning(@user) do
      @patient = create :patient, name: 'Susie Everyteen',
                                  primary_phone: '111-222-3333',
                                  appointment_date: Time.zone.now + 5.days,
                                  initial_call_date: Time.zone.now + 3.days
    end
  end

  describe 'natural initializing - everything okay alarm' do
    it 'should be available on a patient creation' do
      assert_not_nil @patient.versions
      assert_kind_of PaperTrailVersion, @patient.versions.first
    end

    it 'should record the creating user' do
      assert_equal @patient.created_by, @user
    end
  end

  describe 'methods' do
    before do
      with_versioning do
        @clinic = create :clinic
        @patient.update name: 'Yolo',
                        primary_phone: '123-456-9999',
                        appointment_date: Time.zone.now.to_date + 10.days,
                        city: 'Canada',
                        clinic: @clinic,
                        special_circumstances: ['A', '', 'C', ''],
                        pledge_generated_at: Time.zone.now + 5.days

        @track = @patient.versions.first
      end
    end

    it 'should conveniently render the date' do
      assert_equal Time.zone.now.display_date,
                   @track.date_of_change
    end

    it 'should default to System if it cannot find a user' do
      assert_equal @track.changed_by_user, 'System'
    end

    it 'should know whether the actual changed fields are relevant' do
      assert @track.has_changed_fields?
      @track.object_changes = {
        "updated_at" => [1.day.ago, Time.zone.now],
        "identifier" => "D1-1111"
      }
      refute @track.has_changed_fields?
    end

    it 'should return shaped changes as a single dict' do
      assert_equal @track.shaped_changes,
                   { 'appointment_date' => { original: (Time.zone.now + 5.days).display_date, modified: (Time.zone.now + 10.days).display_date },
                     'special_circumstances' => { original: '(empty)', modified: 'A, C' },
                     'clinic_id' => { original: '(empty)', modified: @clinic.name },
                     'pledge_generated_at' => { original: '(empty)', modified: (Time.zone.now + 5.days).strftime('%m/%d/%Y') }
                   }
    end

    it 'should delete old objects' do
      with_versioning do
        # create a patient in the past... will create a papertrail version
        Timecop.freeze(2.years.ago) do
          create :patient, name: 'Patient from long ago',
                            primary_phone: '444-555-6666'
        end

        # come back to the present and remove old records
        # we exepct two records to be deleted: the patient creation, and the
        # corresponding fulfillment
        assert_difference 'PaperTrailVersion.count', -2 do
          PaperTrailVersion.destroy_old
        end
      end
    end

    it 'should scrub PII from Patient versions' do
      with_versioning do
        # Simulate pre-encryption version records by injecting PII into JSON.
        # Before Phase 1 encryption, PaperTrail recorded PII in plaintext.
        version = @patient.versions.first

        version.object = {
          'name' => 'Susie Everyteen',
          'primary_phone' => '1112223333',
          'city' => 'Washington',
          'state' => 'DC',
          'appointment_date' => '2025-01-15',
          'line' => 'DC'
        }
        version.object_changes = {
          'name' => [nil, 'Susie Everyteen'],
          'primary_phone' => [nil, '1112223333'],
          'other_phone' => [nil, '9998887777'],
          'other_contact' => [nil, 'Jane Doe'],
          'other_contact_relationship' => [nil, 'Mother'],
          'county' => [nil, 'Arlington'],
          'zipcode' => [nil, '20001'],
          'appointment_date' => [nil, '2025-01-15'],
          'line' => [nil, 'DC']
        }
        version.save!

        count = PaperTrailVersion.scrub_patient_pii
        assert_operator count, :>=, 1

        version.reload

        # PII should be gone from object
        refute version.object.key?('name'), 'name should be scrubbed from object'
        refute version.object.key?('primary_phone'), 'primary_phone should be scrubbed from object'
        refute version.object.key?('city'), 'city should be scrubbed from object'
        refute version.object.key?('state'), 'state should be scrubbed from object'

        # Non-PII should be preserved in object
        assert version.object.key?('appointment_date'), 'appointment_date should be kept in object'
        assert version.object.key?('line'), 'line should be kept in object'

        # PII should be gone from object_changes
        refute version.object_changes.key?('name'), 'name should be scrubbed from object_changes'
        refute version.object_changes.key?('primary_phone'), 'primary_phone should be scrubbed from object_changes'
        refute version.object_changes.key?('other_phone'), 'other_phone should be scrubbed from object_changes'
        refute version.object_changes.key?('other_contact'), 'other_contact should be scrubbed from object_changes'
        refute version.object_changes.key?('other_contact_relationship'), 'other_contact_relationship should be scrubbed'
        refute version.object_changes.key?('county'), 'county should be scrubbed from object_changes'
        refute version.object_changes.key?('zipcode'), 'zipcode should be scrubbed from object_changes'

        # Non-PII should be preserved in object_changes
        assert version.object_changes.key?('appointment_date'), 'appointment_date should be kept in object_changes'
        assert version.object_changes.key?('line'), 'line should be kept in object_changes'
      end
    end

    it 'should not modify non-Patient versions during scrub' do
      with_versioning do
        config = create :config
        config_version = config.versions.first

        original_changes = config_version.object_changes&.dup

        PaperTrailVersion.scrub_patient_pii

        config_version.reload
        assert_equal original_changes, config_version.object_changes
      end
    end
  end

  # ensure that paper trail is versioning properly
  describe 'attachments to objects in general' do
    before do
      with_versioning do
        @config = create :config
      end
    end

    it "should attach versions to config" do
      assert_equal 1, @config.versions.count
      assert_difference '@config.versions.count', 1 do
        with_versioning do
          @config.update config_value: { options: ['Metallica'] }
        end
      end
    end
  end
end
