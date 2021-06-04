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
                   { 'name' => { original: 'Susie Everyteen', modified: 'Yolo' },
                     'primary_phone' => { original: '1112223333', modified: '1234569999' },
                     'appointment_date' => { original: (Time.zone.now + 5.days).display_date, modified: (Time.zone.now + 10.days).display_date },
                     'special_circumstances' => { original: '(empty)', modified: 'A, C' },
                     'city' => { original: '(empty)', modified: 'Canada' },
                     'clinic_id' => { original: '(empty)', modified: @clinic.name },
                     'pledge_generated_at' => { original: '(empty)', modified: (Time.zone.now + 5.days).strftime('%m/%d/%Y') }
                   }
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
          @config.update config_value: { options: 'Metallica' }
        end
      end
    end
  end
end
