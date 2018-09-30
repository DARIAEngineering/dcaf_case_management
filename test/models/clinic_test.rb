require 'test_helper'

class ClinicTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @clinic = create :clinic, created_by: @user
  end

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
      dupe_clinic = build :clinic, name: clinic_name, created_by: @user
      refute dupe_clinic.valid?
    end
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @clinic.respond_to? field
        assert @clinic[field]
      end
    end

    it 'should respond to history methods' do
      assert @clinic.respond_to? :history_tracks
      assert @clinic.history_tracks.count > 0
    end

    it 'should have accessible userstamp methods' do
      assert @clinic.respond_to? :created_by
      assert @clinic.created_by
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
  end

  describe 'callbacks' do
    describe 'updating coordinates when address changes' do
      before { @cached_api_key = ENV['GOOGLE_GEO_API_KEY'] }
      after { ENV['GOOGLE_GEO_API_KEY'] = @cached_api_key }

      it 'should update coordinates on address change' do
        ENV['GOOGLE_GEO_API_KEY'] = '123'
        geocoder_coordinates = [38.8976633,77.0365739]
        fake_lat_lng = OpenStruct.new(ll: geocoder_coordinates.join(','))
        Geokit::Geocoders::GoogleGeocoder.stub :geocode, fake_lat_lng do
          @clinic.update city: 'Arlington'
        end

        assert_equal geocoder_coordinates, @clinic.coordinates
      end
    end
  end
end
