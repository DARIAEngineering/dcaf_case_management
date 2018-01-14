# Create, edit, and update patients. The main patient view is edit.
class PatientsController < ApplicationController
  before_action :redirect_unless_has_data_access, only: [:index]
  before_action :find_patient, only: [:edit, :update, :download]
  rescue_from Mongoid::Errors::DocumentNotFound,
              with: -> { redirect_to root_path }

  def index
    respond_to do |format|
      format.csv do
        render_csv
      end
    end
  end

  def create
    patient = Patient.new patient_params

    patient.created_by = current_user
    if patient.save
      flash[:notice] = 'A new patient has been successfully saved'
    else
      flash[:alert] = "Errors prevented this patient from being saved: #{patient.errors.full_messages.to_sentence}"
    end

    current_user.add_patient patient
    redirect_to root_path
  end

  def pledge
    @patient = Patient.find params[:patient_id]
    respond_to do |format|
      format.js
    end
  end

  # download a filled out pledge form based on patient record
  def download
    if params[:case_manager_name].blank?
      flash[:alert] = "You need to enter your name in the box to sign and download the pledge"
      redirect_to edit_patient_path @patient
    else
      now = Time.zone.now.strftime('%Y%m%d')
      pdf_filename = "#{@patient.name}_pledge_form_#{now}.pdf"
      pdf = PledgeFormGenerator.new(current_user,
                                    @patient,
                                    params[:case_manager_name].to_s)
                               .generate_pledge_pdf
      @patient.update pledge_generated_at: Time.zone.now,
                      pledge_generated_by: current_user
      send_data pdf.render, filename: pdf_filename, type: 'application/pdf'
    end
  end

  def edit
    @note = @patient.notes.new
    @external_pledge = @patient.external_pledges.new
  end

  def update
    @patient.last_edited_by = current_user
    if @patient.update_attributes patient_params
      @patient.reload
      flash.now[:notice] = "Patient info successfully saved at #{Time.zone.now.display_timestamp}"
    else
      error = @patient.errors.full_messages.to_sentence
      flash.now[:alert] = error
      response.status = :not_acceptable
    end
    respond_to { |format| format.js }
  end

  def data_entry
    @patient = Patient.new
  end

  def data_entry_create
    @patient = Patient.new patient_params
    @patient.created_by = current_user

    if @patient.save
      flash[:notice] = "#{@patient.name} has been successfully saved! Add notes and external pledges, confirm the hard pledge and the #{FUND} pledge amounts are the same, and you're set."
      redirect_to edit_patient_path @patient
    else
      flash[:alert] = "Errors prevented this patient from being saved: #{@patient.errors.full_messages.to_sentence}"
      render 'data_entry'
    end
  end

  private

  def find_patient
    @patient = Patient.find params[:id]
  end

  PATIENT_DASHBOARD_PARAMS = [
    :name, :last_menstrual_period_days, :last_menstrual_period_weeks,
    :appointment_date, :primary_phone
  ].freeze

  PATIENT_INFORMATION_PARAMS = [
    :line, :age, :race_ethnicity, :language,
    :voicemail_preference, :city, :state, :county, :zip, :other_contact, :other_phone,
    :other_contact_relationship, :employment_status, :income,
    :household_size_adults, :household_size_children, :insurance, :referred_by,
    special_circumstances: []
  ].freeze

  ABORTION_INFORMATION_PARAMS = [
    :clinic_id, :resolved_without_fund, :referred_to_clinic,
    :procedure_cost, :patient_contribution, :naf_pledge, :fund_pledge
  ].freeze

  FULFILLMENT_PARAMS = [
    fulfillment: [:fulfilled, :procedure_date, :gestation_at_procedure,
                  :procedure_cost, :check_number, :date_of_check]
  ].freeze

  OTHER_PARAMS = [:urgent_flag, :initial_call_date, :pledge_sent].freeze

  def patient_params
    params.require(:patient).permit(
      [].concat(PATIENT_DASHBOARD_PARAMS, PATIENT_INFORMATION_PARAMS,
                ABORTION_INFORMATION_PARAMS, OTHER_PARAMS, FULFILLMENT_PARAMS)
    )
  end

  def render_csv
    now = Time.zone.now.strftime('%Y%m%d')
    csv_filename = "patient_data_export_#{now}.csv"
    set_headers(csv_filename)

    response.status = 200

    self.response_body = Patient.to_csv
  end

  def set_headers(filename)
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{filename}\""
    headers['X-Accel-Buffering'] = 'no'
    headers["Cache-Control"] = "no-cache"
    headers.delete("Content-Length")
  end
end
