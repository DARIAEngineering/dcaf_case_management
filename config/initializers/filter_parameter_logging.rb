# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc

  # Custom
  :password,
  :email,
  :name,
  :age,
  :employment_status,
  :primary_phone,
  :secondary_phone,
  :city,
  :state,
  :zip,
  :appointment_date,
  :insurance,
  :street_address_1,
  :street_address_2,
  :shared_flag,
  :income,
  :special_circumstances,
  :procedure_cost,
  :procedure_date,
  :procedure_completed_date,
  :household_size,
  :full_text,
  :search
]
