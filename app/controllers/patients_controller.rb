# Create and update patients, plus the main patient view in edit
class PatientsController < ApplicationController
  before_action :find_patient, only: [:edit, :update]
  rescue_from Mongoid::Errors::DocumentNotFound,
              with: -> { redirect_to root_path }

  def create
    patient = Patient.new patient_params

    patient.created_by = current_user
    (patient.pregnancy || patient.build_pregnancy).created_by = current_user
    (patient.fulfillment || patient.build_fulfillment).created_by = current_user
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
    @external_pledge = @patient.external_pledges.new
  end

  def update
    puts params
    if @patient.update_attributes patient_params
      head :ok
    else
      head :bad_request
    end
  end

  # The following two methods are for mass data entry and
  # should be turned off when not in use
  def data_entry
    @patient = Patient.new
    @pregnancy = @patient.build_pregnancy
  end

  def data_entry_create # temporary
    @patient = Patient.new patient_params
    @patient.created_by = current_user
    @pregnancy = @patient.pregnancy || @patient.build_pregnancy
    @pregnancy.created_by = current_user
    (@patient.fulfillment || @patient.build_fulfillment).created_by = current_user

    if @patient.save
      flash[:notice] = "#{@patient.name} has been successfully saved! Add notes and external pledges, confirm the hard pledge and the soft pledge amounts are the same, and you're set."
      current_user.add_patient @patient
      redirect_to edit_patient_path @patient
    else
      flash[:alert] = "Errors prevented this patient from being saved: #{@patient.errors.full_messages.to_sentence}"
      render 'data_entry'
    end
  end
  # end routes to be turned off when not in active use

  private

  def find_patient
    @patient = Patient.find params[:id]
  end

  def patient_params
    params.require(:patient).permit(
      :name, :primary_phone, :other_contact, :other_phone,
      :other_contact_relationship, :line, :voicemail_preference, :spanish,
      # fields in dashboard
      # :clinic_name,
      :appointment_date,
      :age, :race_ethnicity, :city, :state, :zip, :employment_status, :income,
      :household_size_adults, :household_size_children, :insurance,
      :referred_by, :initial_call_date, :urgent_flag,
      :clinic_id,
      pregnancy: [:last_menstrual_period_days, :last_menstrual_period_weeks,
                  :resolved_without_dcaf, :referred_to_clinic, :procedure_cost,
                  :pledge_sent, :patient_contribution, :naf_pledge, :dcaf_soft_pledge],
      special_circumstances: [],
      fulfillment: [:fulfilled, :procedure_date, :gestation_at_procedure,
                    :procedure_cost, :check_number, :check_date]
    )
  end
end
