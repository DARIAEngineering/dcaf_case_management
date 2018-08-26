require 'csv'

# Methods pertaining to patient export
module Exportable
  extend ActiveSupport::Concern

  CSV_EXPORT_FIELDS = {
    "BSON ID" => :id,
    # "Identifier" => :identifier,
    "Archived?" => :archived?,
    "Has Alt Contact?" => :has_alt_contact,
    "Voicemail Preference" => :voicemail_preference,
    "Line" => :line,
    "Language" => :preferred_language,
    "Age" => :age_range,
    "State" => :state,
    "County" => :county,
    "City" => :city,
    "Race or Ethnicity" => :race_ethnicity,
    "Employment Status" => :employment_status,
    "Minors in Household" => :get_household_size_children,
    "Adults in Household" => :get_household_size_adults,
    "Insurance" => :insurance,
    "Income" => :income,
    "Referred By" => :referred_by,
    "Referred to clinic by fund" => :referred_to_clinic,
    "Appointment Date" => :appointment_date,
    "Initial Call Date" => :initial_call_date,
    "Urgent?" => :urgent_flag,
    "Has Special Circumstances" => :has_special_circumstances,
    "LMP at intake (weeks)" => :last_menstrual_period_weeks,
    "Abortion cost" => :procedure_cost,
    "Patient contribution" => :patient_contribution,
    "NAF pledge" => :naf_pledge,
    "Fund pledge" => :fund_pledge,
    "Clinic" => :export_clinic_name,
    "Pledge sent" => :pledge_sent,
    "Resolved without fund assistance" => :resolved_without_fund,
    "Pledge generated time" => :pledge_generated_at,

    # Call related
    "Timestamp of first call" => :first_call_timestamp,
    "Timestamp of last call" => :last_call_timestamp,
    "Call count" => :call_count,
    "Reached Patient call count" => :reached_patient_call_count,

    # Fulfillment related
    "Fulfilled" => :fulfilled,
    "Procedure date" => :procedure_date,
    "Gestation at procedure in weeks" => :gestation_at_procedure,
    "Procedure cost" => :procedure_cost_amount,
    "Check number" => :check_number,
    "Date of Check" => :date_of_check,

    # Notes
    "Notes Count" => :notes_count,

    # TODO clinic stuff

    # External Pledges
    "External Pledge Count" => :external_pledge_count,
    "External Pledges Sum" => :external_pledge_sum,
    "All External Pledges" => :all_external_pledges
    
    
    # TODO test to confirm that specific blacklisted fields aren't being exported
  }.freeze

  def fulfilled
    fulfillment.try :fulfilled
  end

  def archived?
    if is_a?(Patient)
      false
    else
      true
    end
  end

  def get_household_size_children 
    if is_a?(Patient)
      household_size_children
    else
      nil
    end
  end

  def get_household_size_adults
    if is_a?(Patient)
      household_size_adults
    else
      nil
    end
  end

  def procedure_date
    fulfillment.try :procedure_date
  end

  def gestation_at_procedure
    fulfillment.try :gestation_at_procedure
  end

  def procedure_cost_amount
    fulfillment.try :procedure_cost
  end

  def check_number
    fulfillment.try :check_number
  end

  def date_of_check
    fulfillment.try :date_of_check
  end

  def first_call_timestamp
    calls.first.try :created_at
  end

  def last_call_timestamp
    calls.last.try :created_at
  end

  def call_count
    calls.count
  end

  def reached_patient_call_count
    reached_calls = calls.select {|call| call.status == "Reached patient"}
    reached_calls.count
  end

  def export_clinic_name
    clinic.try :name
  end

  def preferred_language
    case language
    when nil, ''
      'English'
    else
      language
    end
  end

  def get_field_value_for_serialization(field)
    value = public_send(field)
    if value.is_a?(Array)
      # Use simpler serialization for Array values than the default (`to_s`)
      value.reject(&:blank?).join(', ')
    else
      value
    end
  end
  
  def external_pledge_count
    external_pledges.count
  end
  
  def external_pledge_sum
    sum = 0
    all_pledges = external_pledges.all
    
    all_pledges.each do |pledge|
      sum += pledge.try :amount
    end
    sum
  end
  
  def all_external_pledges
    external_pledges.map { |x| "#{x.source} - #{x.amount}" }.join('; ')
  end
  
  
  

  class_methods do
    def csv_header
      Enumerator.new do |y|
        y << CSV.generate_line(CSV_EXPORT_FIELDS.keys, encoding: 'utf-8')
      end
    end
    def to_csv
      Enumerator.new do |y|
        each do |export|
          row = CSV_EXPORT_FIELDS.values.map{ |field| export.get_field_value_for_serialization(field) }
          y << CSV.generate_line(row, encoding: 'utf-8')
        end
      end
    end
  end
end
