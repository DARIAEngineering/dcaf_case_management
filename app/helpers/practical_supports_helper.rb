module PracticalSupportsHelper
  # options_plus_current lives in PatientsHelper
  include PatientsHelper

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

    options_plus_current(options, current_value)
  end

  def practical_support_source_options(current_value = nil)
    options = [nil, ActsAsTenant.current_tenant.full_name] +
      Config.find_or_create_by(config_key: 'external_pledge_source').options +
      [
        [ t('common.patient'), 'Patient' ],
        [ t('common.clinic'), 'Clinic' ],
        [ t('patient.helper.practical_support.other'), 'Other (see notes)' ],
        [ t('patient.helper.practical_support.not_sure_yet'), 'Not sure yet (see notes)' ]
      ]

    options_plus_current(options, current_value)
  end

  def practical_support_guidance_link
    maybe_url = Config.find_or_create_by(config_key: 'practical_support_guidance_url').options.first

    url = UriService.new(maybe_url).uri

    return unless url.present?
    link_to t('patient.practical_support.guidance_link', fund: ActsAsTenant.current_tenant.name), url.to_s, target: '_blank'
    # "For guidance on practical support, view the #{link_content}."
  end
end
