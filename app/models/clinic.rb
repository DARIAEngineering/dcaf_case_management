# Object representing a clinic that a patient is going to.
class Clinic < ApplicationRecord
  acts_as_tenant :fund

  # Concerns
  include PaperTrailable

  # Clinics intentionally excluded from ClinicFinder are assigned the zip 99999.
  # e.g. so a fund can have an 'OTHER CLINIC' catchall.
  EXCLUDED_ZIP = '99999'

  # Scopes
  # Is gestational_limit either nil or above x?
  scope :gestational_limit_above, ->(gestation) {
    where(gestational_limit: nil).or(where(gestational_limit: gestation..))
  }

  # Validations
  COSTS = [
    :costs_5wks, :costs_6wks, :costs_7wks, :costs_8wks, :costs_9wks,
    :costs_10wks, :costs_11wks, :costs_12wks, :costs_13wks, :costs_14wks,
    :costs_15wks, :costs_16wks, :costs_17wks, :costs_18wks, :costs_19wks,
    :costs_20wks, :costs_21wks, :costs_22wks, :costs_23wks, :costs_24wks,
    :costs_25wks, :costs_26wks, :costs_27wks, :costs_28wks, :costs_29wks,
    :costs_30wks
  ].freeze

  validates :gestational_limit, *COSTS, numericality: { only_integer: true,
                                                        allow_nil: true,
                                                        greater_than_or_equal_to: 0 }

  # Callbacks
  before_save :update_coordinates, if: :address_changed?

  # Validations
  validates :name, :street_address, :city, :state, :zip, presence: true
  validates :name, :street_address, :city, :state, :zip, :phone, :fax, :email_for_pledges,
            length: { maximum: 150 }
  validates_uniqueness_to_tenant :name

  # Methods
  def display_location
    return nil if city.blank? || state.blank?
    "#{city}, #{state}"
  end

  def display_coordinates
    coordinates.map(&:to_f)
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
