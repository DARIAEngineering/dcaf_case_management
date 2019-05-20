# require 'test_helper'
# require_relative '../lib/clinic_finder/gestation_helper'

# class TestGestationHelper < TestClass
#   def setup
#     @helper = ClinicFinder::GestationHelper.new(10)
#     @clinic = {
#       'street_address': '2025 Pacific',
#       'city': 'Los Angeles',
#       'state': 'CA',
#       'zip': 90291,
#       'accepts_naf': true,
#       'gestational_limit': 119,
#       'costs_9wks': 350,
#       'costs_12wks': 350,
#       'costs_18wks': nil,
#       'costs_24wks': nil,
#       'costs_30wks': nil
#     }
#   end

#   def test_that_initialize_sets_gestational_age_variable
#     assert_equal 10, @helper.gestational_age
#   end

#   def test_that_initialize_sets_gestational_weeks_variable
#     assert_equal 2, @helper.gestational_weeks
#   end

#   def test_that_gestational_limit_greater_than_ga_is_true
#     assert_equal true, @helper.within_gestational_limit?(30)
#   end

#   def test_that_gestational_limit_less_than_ga_is_false
#     assert_equal false, @helper.within_gestational_limit?(5)
#   end

#   def test_that_gestational_limit_equal_to_ga_is_false
#     assert_equal false, @helper.within_gestational_limit?(10)
#   end

#   def test_gestational_tier_under_lower_bound
#     assert_equal 'costs_9wks', @helper.gestational_tier
#   end

#   def test_gestational_tier_within_bound
#     @helper = ClinicFinder::GestationHelper.new(100)
#     assert_equal 'costs_18wks', @helper.gestational_tier
#   end

#   def test_gestational_tier_above_upper_bound
#     @helper = ClinicFinder::GestationHelper.new(400)
#     assert_equal 'costs_30wks', @helper.gestational_tier
#   end
# end
