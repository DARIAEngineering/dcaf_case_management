require 'test_helper'

class ClinicTest < ActiveSupport::TestCase
  before { @clinic = create :clinic }

  describe 'validations' do
    it 'should build' do
      assert @clinic.valid?
    end

    [:name, :street_address, :city, :state, :zip].each do |attr|
      it "requires a #{attr}" do
        @clinic[attr] = nil
        refute @clinic.valid?
      end
    end

    it 'should be unique on name' do
      clinic_name = @clinic.name
      dupe_clinic = build :clinic, name: clinic_name
      refute dupe_clinic.valid?
    end
  end

  describe 'concerns' do
    it 'should respond to history methods' do
      assert @clinic.respond_to? :versions
      assert @clinic.respond_to? :created_by
      assert @clinic.respond_to? :created_by_id
    end
  end

  describe 'methods' do
    describe 'display_location' do
      it 'should display city and state if both are present' do
        [:city, :state].each do |attr|
          stowed_attribute = @clinic[attr]
          @clinic[attr] = nil
          assert_nil @clinic.display_location
          @clinic[attr] = stowed_attribute
        end

        assert_equal @clinic.display_location, 'Washington, DC'
      end
    end

    describe 'full address' do
      it 'should return an address all fields are present' do
        [:street_address, :city, :state, :zip].each do |attr|
          stowed_attribute = @clinic[attr]
          @clinic[attr] = nil
          assert_nil @clinic.full_address
          @clinic[attr] = stowed_attribute
        end

        assert_equal @clinic.full_address,
                     '123 Fake Street, Washington, DC 20011'
      end
    end

    describe 'updating all coordinates' do
      it 'should raise if no geocoder api key is set' do
        assert_raises Exceptions::NoGoogleGeoApiKeyError do
          Clinic.update_all_coordinates
        end
      end

      describe 'having a key' do
        before { Geokit::Geocoders::GoogleGeocoder.api_key = '123' }
        after { Geokit::Geocoders::GoogleGeocoder.api_key = nil }

        it 'should call the update' do
          fake_coordinates = [23, 23]
          fake_geo = OpenStruct.new lat: fake_coordinates.first, lng: fake_coordinates.last
          Geokit::Geocoders::GoogleGeocoder.stub :geocode, fake_geo do
            Clinic.update_all_coordinates
          end
          @clinic.reload
          assert_equal fake_coordinates, @clinic.coordinates
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'updating coordinates when address changes' do
      before { Geokit::Geocoders::GoogleGeocoder.api_key = '123' }
      after { Geokit::Geocoders::GoogleGeocoder.api_key = nil }

      it 'should update coordinates on address change' do
        fake_geo = OpenStruct.new lat: 38.8976633, lng: 77.0365739
        Geokit::Geocoders::GoogleGeocoder.stub :geocode, fake_geo do
          @clinic.update city: 'Arlington'
        end

        assert_equal [fake_geo.lat, fake_geo.lng],
                     @clinic.display_coordinates
      end
    end
  end

  describe 'scopes' do
    describe 'gestational_limit_above' do
      before { Clinic.destroy_all }

      it 'should filter out clinics unless the gestational_limit is above the cutoff in days' do
        no_gl_clinic = create :clinic
        gl_filtered_clinic = create :clinic, gestational_limit: 100
        gl_kept_clinic = create :clinic, gestational_limit: 240
        # Should return the clinics with no specified GL and a GL above 150
        gl_above_clinics = Clinic.gestational_limit_above 150

        assert_equal 2, gl_above_clinics.count
        assert_includes gl_above_clinics, no_gl_clinic
        assert_includes gl_above_clinics, gl_kept_clinic
        assert_not_includes gl_above_clinics, gl_filtered_clinic
      end
    end
  end
end
