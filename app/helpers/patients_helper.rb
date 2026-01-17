# Functions primarily related to populating selects on patient edit view.
require 'state_geo_tools'
module PatientsHelper
  def weeks_options
    (1..40).map { |i| [t('patient.helper.week', count: i), i] }.unshift [nil, nil]
  end

  def days_options
    (0..6).map { |i| [t('patient.helper.day', count: i), i] }.unshift [nil, nil]
  end

  def race_ethnicity_options
    [ nil,
      [ t('patient.helper.race.white_caucasian'),                  'White/Caucasian' ],
      [ t('patient.helper.race.black_african_american'),           'Black/African-American' ],
      [ t('patient.helper.race.hispanic_latino'),                  'Hispanic/Latino'],
      [ t('patient.helper.race.asian_south_asian'),                'Asian or South Asian'],
      [ t('patient.helper.race.native_hawaiian_pacific_islander'), 'Native Hawaiian or Pacific Islander'],
      [ t('patient.helper.race.native_american'),                  'Native American'],
      [ t('patient.helper.race.mixed_race_ethnicity'),             'Mixed Race/Ethnicity'],
      [ t('patient.helper.race.other'),                            'Other' ],
      [ t('common.prefer_not_to_answer'),                          'Prefer not to answer']
    ]
  end

  # TODO how to i18n the Config?
  def language_options(current_value = nil)
    standard_options = [ [t('patient.helper.language.English'),nil] ]
    # NOTE: don't check hide_standard_dropdown? here because we always want
    # English to be available.
    full_set = standard_options + Config.find_or_create_by(config_key: 'language').options

    options_plus_current(full_set, current_value)
  end

  def voicemail_options(current_value = nil)
    standard_options = [
        [t('dashboard.helpers.voicemail_options.not_specified'), 'not_specified'],
        [t('dashboard.helpers.voicemail_options.no'), 'no'],
        [t('dashboard.helpers.voicemail_options.yes'), 'yes'],
    ]
    full_set = Config.find_or_create_by(config_key: 'voicemail').options

    # voicemail also exempt from hide_standard_dropdown? config
    full_set.push(*standard_options)

    options_plus_current(full_set, current_value)
  end

  def referred_by_options(current_value = nil)
    standard_options = [
      nil,
      [ t('patient.helper.referred_by.clinic'),                       'Clinic' ],
      [ t('patient.helper.referred_by.crime_victim_advocacy_center'), 'Crime victim advocacy center' ],
      [ t('patient.helper.referred_by.fund', fund: ActsAsTenant.current_tenant.name),        "#{ActsAsTenant.current_tenant.name} website or social media" ],
      [ t('patient.helper.referred_by.domestic_violence_org'),        'Domestic violence crisis/intervention org' ],
      [ t('patient.helper.referred_by.family'),                       'Family member' ],
      [ t('patient.helper.referred_by.friend'),                       'Friend' ],
      [ t('patient.helper.referred_by.web_search'),                   'Google/Web search' ],
      [ t('patient.helper.referred_by.homeless'),                     'Homeless shelter' ],
      [ t('patient.helper.referred_by.legal_clinic'),                 'Legal clinic' ],
      [ t('patient.helper.referred_by.naf'),                          'NAF' ],
      [ t('patient.helper.referred_by.nnaf'),                         'NNAF' ],
      [ t('patient.helper.referred_by.other_fund'),                   'Other abortion fund' ],
      [ t('patient.helper.referred_by.prev_patient'),                 'Previous patient' ],
      [ t('patient.helper.referred_by.school'),                       'School' ],
      [ t('patient.helper.referred_by.sexual_assault_crisis_org'),    'Sexual assault crisis org' ],
      [ t('patient.helper.referred_by.youth'),                        'Youth outreach' ],
      [ t('common.prefer_not_to_answer'),                             'Prefer not to answer']
    ]
    full_set = Config.find_or_create_by(config_key: 'referred_by').options
    full_set.push(*standard_options) unless Config.hide_standard_dropdown?

    options_plus_current(full_set, current_value)
  end

  def employment_status_options
    [
      nil,
      [ t('patient.helper.employment.full_time'), 'Full-time'],
      [ t('patient.helper.employment.part_time'), 'Part-time'],
      [ t('patient.helper.employment.unemployed'), 'Unemployed'],
      [ t('patient.helper.employment.odd_jobs'), 'Odd jobs'],
      [ t('patient.helper.employment.student'), 'Student'],
      [ t('common.prefer_not_to_answer'), 'Prefer not to answer']
    ]
  end

  def insurance_options(current_value = nil)
    standard_options = [
      [ t('patient.helper.insurance.none'), 'No insurance' ],
      [ t('patient.helper.insurance.unknown'), 'Don\'t know' ],
      [ t('common.prefer_not_to_answer'), 'Prefer not to answer'],
      [ t('patient.helper.insurance.other'), 'Other (add to notes)' ],
    ]
    full_set = [nil] + Config.find_or_create_by(config_key: 'insurance').options
    full_set.push(*standard_options) unless Config.hide_standard_dropdown?

    options_plus_current(full_set, current_value)
  end

  def procedure_type_options(current_value = nil)
    procedure_type_options = Config.find_or_create_by(config_key: 'procedure_type').options

    return [] if procedure_type_options.blank?

    options_plus_current([nil] + procedure_type_options, current_value)
  end

  def income_options
    [nil,
     [ t('patient.helper.income.under_10'), 'Under $9,999'],
     [ t('patient.helper.income.10_to_15'), '$10,000-14,999'],
     [ t('patient.helper.income.15_to_20'), '$15,000-19,999'],
     [ t('patient.helper.income.20_to_25'), '$20,000-24,999'],
     [ t('patient.helper.income.25_to_30'), '$25,000-29,999'],
     [ t('patient.helper.income.30_to_35'), '$30,000-34,999'],
     [ t('patient.helper.income.35_to_40'), '$35,000-39,999'],
     [ t('patient.helper.income.40_to_45'), '$40,000-44,999'],
     [ t('patient.helper.income.45_to_50'), '$45,000-49,999'],
     [ t('patient.helper.income.50_to_60'), '$50,000-59,999'],
     [ t('patient.helper.income.60_to_75'), '$60,000-74,999'],
     [ t('patient.helper.income.75_plus'), '$75,000 or more'],
     [ t('common.prefer_not_to_answer'), 'Prefer not to answer']
    ]
  end

  def county_options(current_value = nil)
    county_options = Config.find_or_create_by(config_key: 'county').options

    return [] if county_options.blank?

    options_plus_current([nil] + county_options, current_value)
  end

  def household_size_options
    (0..10).map { |i| i }
           .unshift([t('common.prefer_not_to_answer'), -1])
           .unshift([nil, nil])
  end

  def clinic_options
    clinics = Clinic.all.sort_by(&:name)
    active_clinics = clinics.select(&:active)
                            .map { |clinic| [
                              t('patient.abortion_information.clinic_section.clinic_display', clinic_name: clinic.name, city: clinic.city, state: clinic.state),
                              clinic.id,
                              { data: { naf: !!clinic.accepts_naf, medicaid: !!clinic.accepts_medicaid } }
                            ]}
                            .unshift nil

    # Map inactives; if there are any, put in a breaker
    inactive_clinics = clinics.reject(&:active)
                              .map { |clinic| [
                                t('patient.abortion_information.clinic_section.not_currently_working_with_fund', fund: ActsAsTenant.current_tenant.name, clinic_name: clinic.name),
                                clinic.id,
                                { data: { naf: !!clinic.accepts_naf, medicaid: !!clinic.accepts_medicaid } }
                              ]}
    if inactive_clinics.count > 0
      inactive_clinics.unshift ["--- #{t('patient.abortion_information.clinic_section.inactive_clinics').upcase} ---", nil, { disabled: true }]
    end

    active_clinics | inactive_clinics
  end

  def disable_continue?(patient)
    patient.pledge_info_present? ? 'disabled="disabled"' : ''
  end

  def pledge_limit_help_text_options
    Config.find_or_create_by(config_key: 'pledge_limit_help_text').options
  end

  def state_options(current_state)
    StateGeoTools.state_codes.map{ |code| [code,code] }.unshift( [nil, nil] )
      .push( [current_state,current_state] ).uniq
  end

  # helper function for use with `options_for_select`
  # adds `current_value` to `options` if it's not already there
  #
  # call this at the _end_ of `*_options` functions, above, where we want to
  # prevent config clobbering (anything user-configurable)
  #
  # kinda ugly because we're working with a few different datatypes in here
  #   (arrays of strings, and strings)
  def options_plus_current(options, current_value = nil)
    if current_value.present? && options.map { |opt| opt.is_a?(Array) ? opt[-1] : opt }.exclude?(current_value)
      options.push current_value
    end

    options.uniq
  end

  def line_options
    Line.all.sort_by(&:name).map { |x| [x.name, x.id] }
  end

  def appointment_date_display(patient)
    return nil unless patient.appointment_date.present?

    day = patient.appointment_date.strftime("%m/%d/%Y")
    if patient.appointment_time
      time = patient.appointment_time.strftime("%l:%M %p").strip
      day = "#{day} @ #{time}"
    end
    if patient.multiday_appointment?
      day = "#{day} (#{t('patient.abortion_information.clinic_section.multi_day')})"
    end
    return day
  end

  def appointment_date_sort_value(patient)
    return 0 unless patient.appointment_date.present?

    timestamp = patient.appointment_date.to_time
    if patient.appointment_time
      timestamp = timestamp.change(hour: patient.appointment_time.hour, min: patient.appointment_time.min)
    end
    timestamp.to_i
  end

  def language_badge(patient)
    return if patient.language.blank? || patient.language == 'English'
    color = ['badge-primary', 'badge-secondary', 'badge-success', 'badge-info', 'badge-warning', 'badge-dark'][patient.preferred_language.bytes.sum % 6]
    content_tag :span, t('common.language_speaker', language: patient.language), class: "badge #{color}"
  end
end
