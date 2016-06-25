module PregnanciesHelper
  def weeks_options
    (1..30).map { |i| [pluralize(i, 'week'), i] }
  end

  def days_options
    (0..6).map { |i| [pluralize(i, 'day'), i] }
  end

  def race_ethnicity_options
    ['White/Caucasian', 'Black/African-American', 'Hispanic/Latino',
     'Asian or South Asian', 'Native Hawaiian or Pacific Islander',
     'Native American', 'Mixed Race/Ethnicity', 'Other']
  end

  def employment_status_options
    ['Full-time', 'Part-time', 'Unemployed', 'Odd jobs', 'Student']
  end

  def insurance_options
    ['DC Medicaid', 'MD MCHIP', 'MD Medical Assistance for Families (MA4F)',
     'VA Medicaid/CHIP', 'Other State Medicaid',
     'Private or employer-sponsored health insurance',
     'No Insurance', "Don't Know"]
  end

  def income_options
    ['Under $9,999 (less than $192/week)', '$10,000-$14,999 ($192-287/week)',
     '$15,000-19,999 ($288-384/week)', '$20,000-24,999 ($385-480/week)',
     '$25,000-29,999 ($481-576/week)', '$30,000-34,999 ($577-672/week)',
     '$35,000-39,000 ($673-768/week)', '$40,000-44,999 ($769-864/week)',
     '$45,000-49,999 ($865-961/week)', '$50,000-$59,999 ($962-1153/week)',
     '$60,000-$74,999 ($1154-1441/week)',
     '$75,000 or more/year ($1442 or more/week)']
  end

  def referred_by_options
    ['Clinic', 'Crime Victim Advocacy Center', 'DCAF Website or Social Media',
     'Domestic Violence Crisis/Intervention Org', 'Family Member', 'Friend',
     'Google/Web Search', 'Homeless Shelter', 'Legal Clinic', 'NAF', 'NNAF',
     'Other Abortion Fund', 'Previous Patient', 'School',
     'Sexual Assault Crisis Org', 'Youth Outreach']
  end

  def special_circumstances_options
    ['Domestic Violence', 'Fetal Anomaly', 'Homeless', 'Immigrant', 'Incest',
     'Maternal Health', 'Other', 'Rape', 'Undocumented/Non-Citizen']
  end
end
