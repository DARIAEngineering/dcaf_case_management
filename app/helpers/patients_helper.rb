# Functions primarily related to populating selects on patient edit view.
module PatientsHelper
  def weeks_options
    (1..30).map { |i| [t('patient.helper.week', count: i), i] }.unshift [nil, nil]
  end

  def days_options
    (0..6).map { |i| [t('patient.helper.day', count: i), i] }.unshift [nil, nil]
  end

  def race_ethnicity_options
    [ [ nil ],
      [ t('patient.helper.race.white_caucasian'),                  'White/Caucasian' ],
      [ t('patient.helper.race.black_afican_american'),            'Black/African-American' ],
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
    standard_options = [ nil, [t('patient.helper.language.English'),'English']]
    standard_options + Config.find_or_create_by(config_key: 'language').options
  end

  def referred_by_options
    standard_options = [
      nil,
      [ t('patient.helper.refer.clinic'),                 'Clinic' ],
      [ t('patient.helper.refer.cvac'),                   'Crime victim advocacy center' ],
      [ t('patient.helper.refer.fund', fund: "#{FUND}"),  "#{FUND} website or social media" ],
      [ t('patient.helper.refer.dv_org'),                 'Domestic violence crisis/intervention org' ],
      [ t('patient.helper.refer.family'),                 'Family member' ],
      [ t('patient.helper.refer.friend'),                 'Friend' ],
      [ t('patient.helper.refer.search'),                 'Google/Web search' ],
      [ t('patient.helper.refer.homeless'),               'Homeless shelter' ],
      [ t('patient.helper.refer.legal'),                  'Legal clinic' ],
      [ t('patient.helper.refer.naf'),                    'NAF' ],
      [ t('patient.helper.refer.nnaf'),                   'NNAF' ],
      [ t('patient.helper.refer.other_fund'),             'Other abortion fund' ],
      [ t('patient.helper.refer.prev_patient'),           'Previous patient' ],
      [ t('patient.helper.refer.school'),                 'School' ],
      [ t('patient.helper.refer.crisis_org'),             'Sexual assault crisis org' ],
      [ t('patient.helper.refer.youth'),                  'Youth outreach' ], ]
    standard_options + Config.find_or_create_by(config_key: 'referred_by').options
  end

  def employment_status_options
    [
      nil,
      [ t('patient.helper.employ.full'), 'Full-time'],
      [ t('patient.helper.employ.part'), 'Part-time'],
      [ t('patient.helper.employ.unemp'), 'Unemployed'],
      [ t('patient.helper.employ.odd'), 'Odd jobs'],
      [ t('patient.helper.employ.student'), 'Student'],
    ]
  end

  def insurance_options
    standard_options = [
      [ t('patient.helper.insurance.none'), 'No insurance' ],
      [ t('patient.helper.insurance.unknown'), 'Don\'t know' ],
      [ t('patient.helper.insurance.other'), 'Other (add to notes)' ],
    ]
    [nil] + Config.find_or_create_by(config_key: 'insurance').options + standard_options
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
                              .map { |clinic| ["(Not currently working with #{FUND}) - #{clinic.name}", clinic.id] }
                              .unshift ['--- INACTIVE CLINICS ---', nil]
    active_clinics | inactive_clinics
  end

  def disable_continue?(patient)
    patient.pledge_info_present? ? 'disabled="disabled"' : ''
  end

  def pledge_limit_help_text_options
    Config.find_or_create_by(config_key: 'pledge_limit_help_text').options
  end
end
