# Populates selects etc on patient edit view
module PatientsHelper
  def weeks_options
    (1..30).map { |i| [pluralize(i, 'week'), i] }.unshift [nil, nil]
  end

  def days_options
    (0..6).map { |i| [pluralize(i, 'day'), i] }.unshift [nil, nil]
  end

  def race_ethnicity_options
    [nil, 'White/Caucasian', 'Black/African-American', 'Hispanic/Latino',
     'Asian or South Asian', 'Native Hawaiian or Pacific Islander',
     'Native American', 'Mixed Race/Ethnicity', 'Other']
  end

  def employment_status_options
    [nil, 'Full-time', 'Part-time', 'Unemployed', 'Odd jobs', 'Student']
  end

  def insurance_options
    [nil, 'DC Medicaid', 'MD MCHIP',
     'MD Medical Assistance for Families (MA4F)', 'VA Medicaid/CHIP',
     'Other state Medicaid', 'Private or employer-sponsored health insurance',
     'No insurance', 'Don\'t know', 'Other (add to notes)']
  end

  def income_options
    [nil,
     ['Under $9,999 ($192/wk - $833/mo)', 'Under $9,999'],
     ['$10,000-14,999 ($192-287/wk - $834-1250/mo)', '$10,000-14,999'],
     ['$15,000-19,999 ($288-384/wk - $1251-1666/mo)', '$15,000-19,999'],
     ['$20,000-24,999 ($385-480/wk - $1667-2083/mo)', '$20,000-24,999'],
     ['$25,000-29,999 ($481-576/wk - $2084-2499/mo)', '$25,000-29,999'],
     ['$30,000-34,999 ($577-672/wk - $2500-2916/mo)', '$30,000-34,999'],
     ['$35,000-39,999 ($673-768/wk - $2917-3333/mo)', '$35,000-39,999'],
     ['$40,000-44,999 ($769-864/wk - $3334-3749/mo)', '$40,000-44,999'],
     ['$45,000-49,999 ($865-961/wk - $3750-4165/mo)', '$45,000-49,999'],
     ['$50,000-59,999 ($962-1153/wk - $4166-4999/mo)', '$50,000-59,999'],
     ['$60,000-74,999 ($1154-1441/wk - $5000-6249/mo)', '$60,000-74,999'],
     ['$75,000 or more ($1442+ /wk - $6250+ /mo)', '$75,000 or more']
    ]
  end

  def referred_by_options
    [nil, 'Clinic', 'Crime victim advocacy center',
     'DCAF website or social media',
     'Domestic violence crisis/intervention org', 'Family member', 'Friend',
     'Google/Web search', 'Homeless shelter', 'Legal clinic', 'NAF', 'NNAF',
     'Other abortion fund', 'Previous patient', 'School',
     'Sexual assault crisis org', 'Youth outreach']
  end

  def household_size_options
    (1..10).map { |i| i }.unshift [nil, nil]
  end

  def clinic_options
    (ENV['CLINICS'].try(:split, ',') || ['Sample Clinic 1', 'Sample Clinic 2'])
      .unshift nil
  end

  def disable_continue?(patient)
    patient.pregnancy.pledge_info_present? ? 'disabled' : ''
  end
end
