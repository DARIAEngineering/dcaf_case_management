require 'test_helper'

class PaperTrailVersionTest < ActiveSupport::TestCase
  before do
    @user = create :user
    with_versioning do
      PaperTrail.request(whodunnit: @user) do
        @patient = create :patient, name: 'Susie Everyteen',
                                    primary_phone: '111-222-3333',
                                    appointment_date: Time.zone.now + 5.days,
                                    initial_call_date: Time.zone.now + 3.days
      end
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
                        appointment_date: Date.today + 10.days,
                        city: 'Canada',
                        clinic: @clinic,
                        special_circumstances: ['A', '', 'C', '']
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

    # TODO test has_changed_fields?
    # TODO test date_of_change

    it 'should return shaped changes as a single dict' do
      assert_equal @track.shaped_changes,
                   { 'name' => { original: 'Susie Everyteen', modified: 'Yolo' },
                     'primary_phone' => { original: '1112223333', modified: '1234569999' },
                     'appointment_date' => { original: (Date.today + 5.days).display_date, modified: (Date.today + 10.days).display_date },
                     'special_circumstances' => { original: '(empty)', modified: 'A, C' },
                     'city' => { original: '(empty)', modified: 'Canada' },
                     'clinic_id' => { original: '(empty)', modified: @clinic.name },
                   }
    end
  end
end
