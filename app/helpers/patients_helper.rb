# Functions primarily related to populating selects on patient edit view.
require 'state_geo_tools'
module PatientsHelper
  def weeks_options
    (1..30).map { |i| [t('patient.helper.week', count: i), i] }.unshift [nil, nil]
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
      [ t('patient.helper.race.other'),                            'Other' ]
    ]
  end

  # TODO how to i18n the Config?
  def language_options
    standard_options = [ [t('patient.helper.language.English'),nil] ]
    standard_options + Config.find_or_create_by(config_key: 'language').options
  end

  def referred_by_options
    standard_options = [
      nil,
      [ t('patient.helper.referred_by.clinic'),                       'Clinic' ],
      [ t('patient.helper.referred_by.crime_victim_advocacy_center'), 'Crime victim advocacy center' ],
      [ t('patient.helper.referred_by.fund', fund: "#{FUND}"),        "#{FUND} website or social media" ],
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
      [ t('patient.helper.referred_by.youth'),                        'Youth outreach' ], ]
    standard_options + Config.find_or_create_by(config_key: 'referred_by').options
  end

  def employment_status_options
    [
      nil,
      [ t('patient.helper.employment.full_time'), 'Full-time'],
      [ t('patient.helper.employment.part_time'), 'Part-time'],
      [ t('patient.helper.employment.unemployed'), 'Unemployed'],
      [ t('patient.helper.employment.odd_jobs'), 'Odd jobs'],
      [ t('patient.helper.employment.student'), 'Student'],
    ]
  end

  def insurance_options(current_value = nil)
    standard_options = [
      [ t('patient.helper.insurance.none'), 'No insurance' ],
      [ t('patient.helper.insurance.unknown'), 'Don\'t know' ],
      [ t('patient.helper.insurance.other'), 'Other (add to notes)' ],
    ]
    full_set = [nil] + Config.find_or_create_by(config_key: 'insurance').options + standard_options
    # if the current value isn't in the list, push it on.
    # kinda ugly because we're working with a few different datatypes in here.
    if current_value.present? && full_set.map { |opt| opt.is_a?(Array) ? opt[-1] : opt }.exclude?(current_value)
      full_set.push current_value
    end

    full_set.uniq
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
     [ t('patient.helper.income.75_plus'), '$75,000 or more']
    ]
  end

  def household_size_options
    (1..10).map { |i| i }.unshift [nil, nil]
  end

  def clinic_options
    clinics = Clinic.all.sort_by(&:name)
    active_clinics = clinics.select(&:active)
                            .map { |clinic| [clinic.name, clinic.id] }
                            .unshift nil
    inactive_clinics = clinics.reject(&:active)
                              .map { |clinic| [t('patient.abortion_information.clinic_section.not_currently_working_with_fund', fund: FUND, clinic_name: clinic.name), clinic.id] }
                              .unshift ["--- #{t('patient.abortion_information.clinic_section.inactive_clinics').upcase} ---", nil]
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
end
