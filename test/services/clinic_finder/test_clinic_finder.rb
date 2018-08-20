require 'test_helper'
require_relative '../lib/clinic_finder'

# Test initialization and top level methods.
class TestClinicFinderLocator < TestClass
  before do
    pp_oakland = create :clinic, street_address: '1001 Broadway',
                                 city: 'Oakland',
                                 state: 'CA',
                                 zip: '94607',
                                 accepts_naf: false,
                                 accepts_medicaid: false,
                                 gestational_limit: 139,
                                 costs_9wks: 425,
                                 costs_12wks: 475,
                                 costs_18wks: 975
    pp_sf = create :clinic, street_address: '2430 Folsom',
                            city: 'San Francisco',
                            state: 'CA',
                            zip: '94110',
                            accepts_naf: false,
                            accepts_medicaid: false,
                            gestational_limit: 111,
                            costs_9wks: 300,
                            costs_12wks: 325

    @clinics = load_clinic_fixtures
  end

  describe 'initialization with clinics' do
    before do
      @abortron = ClinicFinder::Locator.new @clinics
    end

    it 'should initialize with clinics' do
      assert(@abortron.clinics.find { |c| c.name == 'Butte health clinic' })
      assert_equal @clinics.count, @abortron.clinics.count
      assert_equal @abortron.clinics.count, @abortron.clinic_structs.count
    end

    it 'should have mirroring clinic and clinic_structs on init' do
      @abortron.clinic_structs.each do |clinic_struct|
        clinic = @abortron.clinics.find { |c| c._id == clinic_struct._id }
        clinic.attributes.each_pair do |k, _v|
          attr_value = clinic.instance_variable_get("@#{k}")
          assert_equal attr_value, clinic_struct[k] if attr_value
        end
      end
    end

    it 'should make a patient context obj available' do
      assert @abortron.respond_to? :patient_context
      @abortron.patient_context.yolo = 'goat'
      assert_equal 'goat', @abortron.patient_context.yolo
    end
  end

  describe 'initializing with filters' do
    it 'should filter clinics based on patients gestational age' do
      @abortron = ClinicFinder::Locator.new @clinics,
                                            gestational_age: 150
      @abortron.clinics.each { |clinic| assert clinic.gestational_limit >= 150 }
    end

    it 'should filter clinics based on medicaid preference' do
      @abortron = ClinicFinder::Locator.new @clinics,
                                            medicaid_only: true
      @abortron.clinics.each { |clinic| assert clinic.accepts_medicaid }
    end

    it 'should filter clinics based on naf preference' do
      @abortron = ClinicFinder::Locator.new @clinics,
                                            naf_only: true
      @abortron.clinics.each { |clinic| assert clinic.accepts_naf }
    end
  end

  describe 'locate_nearest_clinics' do
    before do
      @abortron = ClinicFinder::Locator.new @clinics, gestational_age: 150
    end

    it 'should return closest clinics' do
      # This should return the two closest clinics out of the three eligible:
      # One in NM, and the one in LA. It should exclude the one in Monterey CA.
      closest_two_clinics = @abortron.locate_nearest_clinics '73301', limit: 2
      assert closest_two_clinics[0].distance < closest_two_clinics[1].distance
      assert_equal 'Albuquerque medical center', closest_two_clinics[0].name
      assert_equal 'La medical center', closest_two_clinics[1].name

      # It should not return discreet treatment centers in Monterey CA
      # because we're limiting to just the first two
      furthest_clinic = 'Discreet treatment centers of ca'
      assert_nil(closest_two_clinics.find { |c| c.name == furthest_clinic })
    end
  end
end
  # def test_that_initialize_sets_clinic_variable
  # 	assert_kind_of Hash, @abortron.clinics
  # end

  # def test_that_full_addresses_created
  # 	assert_kind_of Array, @abortron.create_full_address(100)
  # end

  # def test_that_full_address_has_needed_fields
  # 	assert_equal [{:name=>"planned_parenthood_oakland", :address=>"1001 Broadway, Oakland, CA"}, {:name=>"planned_parenthood_san_fran", :address=>"2430 Folsom, San Francisco, CA"}, {:name=>"castro_family_planning", :address=>"517 Castro, San Francisco, CA"}, {:name=>"discreet_treatment_centers_of_ca", :address=>"570 Pacific, Monterey, CA"}, {:name=>"albuquerque_medical_center", :address=>"1801 Mountain NW, Albuquerque, NM"}, {:name=>"butte_health_clinic", :address=>"7473 Humboldt, Butte Meadows, CA"}, {:name=>"womens_health_of_venice_beach", :address=>"2025 Pacific, Los Angeles, CA"}, {:name=>"planned_parenthood_la", :address=>"3900 W Manchester, Los Angeles, CA"}, {:name=>"la_medical_center", :address=>"5905 Wilshire, Los Angeles, CA"}], @abortron.create_full_address(100)
  # end

  # def test_that_clinic_coordinates_are_hashes
  # 	addresses = @abortron.create_full_address(100)
  # 	assert_kind_of Hash, @abortron.clinics_coordinates_conversion
  # end

  # def test_that_clinic_coordinates_are_found
  #   @abortron.create_full_address(100)
  #   information = @abortron.clinics_coordinates_conversion
  #   assert_equal [37.8021736,-122.2729171], information["planned_parenthood_oakland"]
  # end

  # def test_that_patient_coordinates_are_found
		# pt_address = "88 Colin P Kelly Jr St, San Francisco, CA"
  # 	pt_mock = MiniTest::Mock.new
  # 	pt_mock.expect(:ll, [37.78226710000001, -122.3912479])
		# Geokit::Geocoders::GoogleGeocoder.stub(:geocode, pt_mock) do
		# 	@abortron.patient_coordinates_conversion(pt_address)
		# end
  # end

  # def test_that_distances_calculated_between_clinics_and_patient
  #   @abortron.create_full_address(100)
  #   @abortron.clinics_coordinates_conversion
  #   @abortron.patient_coordinates_conversion("94117")
  #   first_clinic = {name: "castro_family_planning", distance: 0.92356303468274}
  #   assert_equal first_clinic, @abortron.calculate_distance.first
  # end

  # def test_that_returns_top_3_closest_clinics
  #   @abortron.create_full_address(100)
  #   @abortron.clinics_coordinates_conversion
  #   @abortron.patient_coordinates_conversion("94117")
  #   @abortron.calculate_distance
  #   assert_equal [{:name=>"castro_family_planning", :distance=>0.92356303468274}, {:name=>"planned_parenthood_san_fran", :distance=>1.8319683663768311}, {:name=>"planned_parenthood_oakland", :distance=>9.580895789655901}], @abortron.find_closest_clinics
  # end

  # def test_locate_cheapest_clinic_locates
  #   clinic_result = {name: 'planned_parenthood_oakland', cost: 975}
  #   assert_equal clinic_result, @abortron.locate_cheapest_clinic(gestational_age: 100)[0]
  # end
# end
