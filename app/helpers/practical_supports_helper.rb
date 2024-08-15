module PracticalSupportsHelper
  # options_plus_current lives in PatientsHelper
  include PatientsHelper

  def practical_support_options(current_value = nil)
    standard_options = [
      nil,
      [ t('patient.helper.practical_support.travel_to_region'), 'Travel to the region' ],
      [ t('patient.helper.practical_support.travel_inside_region'), 'Travel inside the region' ],
      [ t('patient.helper.practical_support.lodging'), 'Lodging' ],
      [ t('patient.helper.practical_support.companion'), 'Companion' ],
    ]

    options =
      Config.find_or_create_by(config_key: 'practical_support').options +
        [
          [ t('patient.helper.practical_support.other'), 'Other (see notes)' ]
        ]

    options.push(*standard_options) unless Config.hide_standard_dropdown?

    options_plus_current(options, current_value)
  end

  def practical_support_source_options(current_value = nil)
    options = [nil, ActsAsTenant.current_tenant.full_name] +
      Config.find_or_create_by(config_key: 'external_pledge_source').options

    standard_options = [
      [ t('common.patient'), 'Patient' ],
      [ t('common.clinic'), 'Clinic' ],
      [ t('patient.helper.practical_support.other'), 'Other (see notes)' ],
      [ t('patient.helper.practical_support.not_sure_yet'), 'Not sure yet (see notes)' ]
    ]

    options.push(*standard_options) unless Config.hide_standard_dropdown?

    options_plus_current(options, current_value)
  end

  def practical_support_guidance_link
    maybe_url = Config.find_or_create_by(config_key: 'practical_support_guidance_url').options.first

    url = UriService.new(maybe_url).uri

    return unless url.present?
    link_to t('patient.practical_support.guidance_link', fund: ActsAsTenant.current_tenant.name), url.to_s, target: '_blank'
    # "For guidance on practical support, view the #{link_content}."
  end

  def practical_support_display_text(practical_support)
    content = []
    content.push "(#{t('activerecord.attributes.practical_support.confirmed')})" if practical_support.confirmed?
    content.push "(#{t('activerecord.attributes.practical_support.fulfilled')})" if practical_support.fulfilled?
    content.push practical_support.support_type
    content.push "#{t('common.from')} #{practical_support.source}"
    content.push "#{t('common.on_')} #{practical_support.support_date.display_date}" if practical_support.support_date.present?
    content.push "#{t('common.for')} #{number_to_currency(practical_support.amount)}" if practical_support.amount.present?
    content.push "(#{t('common.purchased_on')} #{practical_support.purchase_date})" if practical_support.purchase_date.present?
    content.join(' ')
  end
end
