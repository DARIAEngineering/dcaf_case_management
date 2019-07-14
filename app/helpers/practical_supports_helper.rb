module PracticalSupportsHelper
  def practical_support_options(current_value = nil)
    standard_options = [
      t('patient.helper.practical_support.travel_to_area'),
      t('patient.helper.practical_support.travel_inside_area'),
      t('patient.helper.practical_support.lodging'),
      t('patient.helper.practical_support.companion'),
    ]
    full_set = [nil] +
      standard_options +
      Config.find_or_create_by(config_key: 'practical_support').options +
      [current_value]
    full_set.uniq
  end

  def practical_support_source_options(current_value = nil)
    full_set = [nil, FUND_FULL] +
      Config.find_or_create_by(config_key: 'external_pledge_source').options +
      ['Clinic', 'Other (see notes)', current_value]
    full_set.uniq
  end
end
