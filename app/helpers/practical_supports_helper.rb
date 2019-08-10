module PracticalSupportsHelper
  def practical_support_options(current_value = nil)
    options = [
      nil,
      [ t('patient.helper.practical_support.travel_to_region'), 'Travel to the region' ],
      [ t('patient.helper.practical_support.travel_inside_region'), 'Travel inside the region' ],
      [ t('patient.helper.practical_support.lodging'), 'Lodging' ],
      [ t('patient.helper.practical_support.companion'), 'Companion' ],
    ] + Config.find_or_create_by(config_key: 'practical_support').options +
      [
        [ t('patient.helper.practical_support.other'), 'Other (see notes)' ]
      ]

    options.push(current_value) if current_value_not_present?(options, current_value)
    options
  end

  def practical_support_source_options(current_value = nil)
    options = [nil, FUND_FULL] +
      Config.find_or_create_by(config_key: 'external_pledge_source').options +
      [
        [ t('common.patient'), 'Patient' ],
        [ t('common.clinic'), 'Clinic' ],
        [ t('patient.helper.practical_support.other'), 'Other (see notes)' ],
        [ t('patient.helper.practical_support.not_sure_yet'), 'Not sure yet (see notes)' ]
      ]

    options.push(current_value) if current_value_not_present?(options, current_value)
    options
  end

  def practical_support_guidance_link
    url = Config.find_or_create_by(config_key: 'practical_support_url').options.first

    content_tag :small do
      link_to t('patient.practical_support.guidance_link', fund: FUND), url, target: '_blank'
    end if url.present?
  end

  private

  def current_value_not_present?(options, current_value)
    # Return true if current value is present in the values of options.
    return false if current_value.blank?
    options.map { |option| option.is_a?(Array) ? option[-1] : option }.exclude? current_value
  end
end
