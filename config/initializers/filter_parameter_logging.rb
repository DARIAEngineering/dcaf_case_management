# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.







Rails.application.config.filter_parameters += [:password, :email, :name, :age, :employment_status, :primary_phone, :secondary_phone, :city, :state, :zip, :appointment_date, :insurance, :street_address_1, :street_address_2, :urgent_flag, :income, :special_circumstances, :procedure_cost, :procedure_date, :procedure_completed_date, :household_size, :full_text]
