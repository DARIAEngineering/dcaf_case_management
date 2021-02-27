# Create, edit, and update patients. The main patient view is edit.
class PatientsController < ApplicationController
  before_action :confirm_admin_user, only: [:destroy]
  before_action :confirm_data_access, only: [:index]
  before_action :find_patient, only: [:edit, :update, :download, :destroy]
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
      flash[:notice] = t('flash.new_patient_save')
      current_user.add_patient patient
    else
      flash[:alert] = t('flash.new_patient_error', error: patient.errors.full_messages.to_sentence)
    end

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
      flash[:alert] = t('flash.pledge_download_alert')
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
    # i18n-tasks-use t('mongoid.attributes.practical_support.confirmed')
    # i18n-tasks-use t('mongoid.attributes.practical_support.source')
    # i18n-tasks-use t('mongoid.attributes.practical_support.support_type')
    @note = @patient.notes.new
    @external_pledge = @patient.external_pledges.new
  end

  def update
    @patient.last_edited_by = current_user
    if @patient.update patient_params
      @patient.reload
      flash.now[:notice] = t('flash.patient_info_saved', timestamp: Time.zone.now.display_timestamp)
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
      flash[:notice] = t('flash.patient_save_success', patient: @patient.name, fund: FUND)
      redirect_to edit_patient_path @patient
    else
      flash[:alert] = t('flash.patient_save_error', error: @patient.errors.full_messages.to_sentence)
      render 'data_entry'
    end
  end

  def destroy
    if @patient.okay_to_destroy? && @patient.destroy
      flash[:notice] = t('flash.patient_removed_database')
      redirect_to authenticated_root_path
    else
      flash[:alert] = t('flash.patient_removed_database_error')
      redirect_to edit_patient_path(@patient)
    end
  end

  private

  def find_patient
    @patient = Patient.find params[:id]
  end

  PATIENT_DASHBOARD_PARAMS = [
    :name, :last_menstrual_period_days, :last_menstrual_period_weeks,
    :appointment_date, :primary_phone, :pronouns
  ].freeze

  PATIENT_INFORMATION_PARAMS = [
    :line, :age, :race_ethnicity, :language, :voicemail_preference, :textable,
    :city, :state, :county, :zipcode, :other_contact, :other_phone,
    :other_contact_relationship, :employment_status, :income,
    :household_size_adults, :household_size_children, :insurance, :referred_by,
    special_circumstances: []
  ].freeze

  ABORTION_INFORMATION_PARAMS = [
    :clinic_id, :resolved_without_fund, :referred_to_clinic, :completed_ultrasound,
    :procedure_cost, :patient_contribution, :naf_pledge, :fund_pledge,
    :fund_pledged_at, :pledge_sent_at
  ].freeze

  FULFILLMENT_PARAMS = [
    fulfillment: [:fulfilled, :procedure_date, :gestation_at_procedure,
                  :fund_payout, :check_number, :date_of_check, :audited]
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

    self.response_body = Enumerator.new do |y|
      Patient.csv_header.each { |e| y << e }
      Patient.to_csv.each { |e| y << e }
      ArchivedPatient.to_csv.each { |e| y << e }
    end
  end

  def set_headers(filename)
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{filename}\""
    headers['X-Accel-Buffering'] = 'no'
    headers["Cache-Control"] = "no-cache"
    headers[Rack::ETAG] = nil # Without this, data doesn't stream
    headers.delete("Content-Length")
  end
end
