# Object representing a clinic that a patient is going to.
class Clinic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Clinics intentionally excluded from ClinicFinder are assigned the zip 99999.
  # e.g. so a fund can have an 'OTHER CLINIC' catchall.
  EXCLUDED_ZIP = '99999'

  # Relationships
  has_many :patients
  has_many :archived_patients

  # Callbacks
  before_save :update_coordinates, if: :address_changed?

  # Fields
  field :name, type: String
  field :street_address, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :phone, type: String
  field :fax, type: String
  field :active, type: Boolean, default: true
  field :accepts_naf, type: Boolean, default: false
  field :accepts_medicaid, type: Boolean, default: false
  field :gestational_limit, type: Integer
  field :coordinates, type: Array
  # costs_5wks, costs_6wks, ..., costs_30wks
  (5..30).each { |i| field "costs_#{i}wks".to_sym, type: Integer }

  # Validations
  validates :name, :street_address, :city, :state, :zip, presence: true
  validates :name, uniqueness: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  # Methods
  def display_location
    return nil if city.blank? || state.blank?

    "#{city}, #{state}"
  end

  def full_address
    return nil if display_location.blank? || street_address.blank? || zip.blank?

    "#{street_address}, #{display_location} #{zip}"
  end

  def update_coordinates
    geocoder = Geokit::Geocoders::GoogleGeocoder
    return unless geocoder.try :api_key

    location = geocoder.geocode full_address
    coordinates = [location.lat, location.lng]
    self.coordinates = coordinates
  end

  def address_changed?
    street_address_changed? || city_changed? || state_changed? || zip_changed?
  end

  def self.update_all_coordinates
    raise Exceptions::NoGoogleGeoApiKeyError.new unless Geokit::Geocoders::GoogleGeocoder.try(:api_key)
    all.each { |clinic| clinic.update_coordinates && clinic.save }
  end
end
