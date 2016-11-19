# Create and update patients, plus the main patient view in edit
class PatientsController < ApplicationController
  before_action :find_patient, only: [:edit, :update]
  rescue_from Mongoid::Errors::DocumentNotFound,
              with: -> { redirect_to root_path }

  def create
    patient = Patient.new patient_params

    patient.created_by = current_user
    (patient.pregnancy || patient.build_pregnancy).created_by = current_user
    if patient.save
      flash[:notice] = 'A new patient has been successfully saved'
    else
      flash[:alert] = "Errors prevented this patient from being saved: #{patient.errors.full_messages.to_sentence}"
    end
    current_user.add_patient patient
    redirect_to root_path
  end

  def edit
    @note = @patient.notes.new
    @pledge = Pledge.new(amount: @patient.pregnancy.dcaf_soft_pledge, patient: @patient, created_by: current_user, pledge_type: 'soft')
  end

  def update
    if @patient.update_attributes patient_params
      head :ok
    else
      head :bad_request
    end
  end

  private

  def find_patient
    @patient = Patient.find params[:id]
  end

  def patient_params
    params.require(:patient).permit(
      :name, :primary_phone, :other_contact, :other_phone,
      :other_contact_relationship, :line, :voicemail_preference, :spanish,
      # fields in dashboard
      :clinic_name,
      :appointment_date,
      :age, :race_ethnicity, :city, :state, :zip, :employment_status, :income,
      :household_size_adults, :household_size_children, :insurance,
      :referred_by, :initial_call_date, :urgent_flag,
      clinic: [:id, :name, :street_address_1, :street_address_2,
               :city, :state, :zip],
      pregnancy: [:last_menstrual_period_days, :last_menstrual_period_weeks,
                  :resolved_without_dcaf, :procedure_cost, :pledge_sent,
                  :patient_contribution, :naf_pledge, :dcaf_soft_pledge],
      special_circumstances: []
    )
  end
end
