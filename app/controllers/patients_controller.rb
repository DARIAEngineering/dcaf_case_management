# Create, edit, and update patients. The main patient view is edit.
class PatientsController < ApplicationController
  include ActionController::Live
  before_action :confirm_admin_user, only: [:destroy]
  before_action :confirm_data_access, only: [:index]
  before_action :find_patient, if: :should_preload_patient_with_versions?
  before_action :find_patient_minimal, if: :should_preload_patient_minimally?
  rescue_from ActiveRecord::RecordNotFound,
              with: -> { redirect_to root_path }

  def index
    # n+1 join here
    respond_to do |format|
      format.csv do
        render_csv
      end
    end
  end

  def create
    patient = Patient.new patient_params

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
                                    params[:case_manager_name].to_s,
                                    current_tenant)
                               .generate_pledge_pdf
      @patient.update pledge_generated_at: Time.zone.now,
                      pledge_generated_by: current_user
      send_data pdf.render, filename: pdf_filename, type: 'application/pdf'
    end
  end

  def fetch_pledge
    endpoint = ENV.fetch('PLEDGE_GENERATOR_ENDPOINT', 'http://localhost:3001/generate')
    basic_auth = { username: ENV.fetch('PLEDGE_GENERATOR_USER', 'apiuser'), password: ENV.fetch('PLEDGE_GENERATOR_TOKEN', 'PLEDGETOKEN') }
    extra_params = params.permit(:case_manager_name, *current_tenant.pledge_config.remote_pledge_extras.map { |x, y| x.to_sym })
    payload = {
      fund: Rails.env.development? ? 'test' : current_tenant.name.downcase,
      base: {
        patient: {
          name: @patient.name,
          identifier: @patient.identifier,
          phone: @patient.primary_phone_display,
          appointment_date: @patient.appointment_date.display_date,
          fund_pledge: @patient.fund_pledge,
          procedure_cost: @patient.procedure_cost,
          patient_contribution: @patient.patient_contribution,
          naf_pledge: @patient.naf_pledge,
        },
        clinic: {
          name: @patient.clinic.name,
          location: @patient.clinic.display_location,
        },
        external_pledges: @patient.external_pledges.where(active: true).map { |x| { source: x.source, amount: x.amount.to_i }} || [],
      },
      extra: extra_params.to_h
    }
    encrypted_payload = { encrypted: encrypt_payload(payload.to_json) }
    result = HTTParty.post(endpoint, body: encrypted_payload, headers: {}, basic_auth: basic_auth)

    if result.ok?
      now = Time.zone.now.strftime('%Y%m%d')
      @patient.update pledge_generated_at: Time.zone.now,
                      pledge_generated_by: current_user
      send_data result.body, filename: "#{@patient.name}_pledge_form_#{now}.pdf", type: 'application/pdf'
    else
      flash[:alert] = t('flash.fetch_pledge_error')
      redirect_to edit_patient_path @patient
    end
  end

  def edit
    # i18n-tasks-use t('activerecord.attributes.practical_support.confirmed')
    # i18n-tasks-use t('activerecord.attributes.practical_support.source')
    # i18n-tasks-use t('activerecord.attributes.practical_support.support_date')
    # i18n-tasks-use t('activerecord.attributes.practical_support.purchase_date')
    # i18n-tasks-use t('activerecord.attributes.practical_support.support_type')
    # i18n-tasks-use t('activerecord.attributes.external_pledge.active')
    # i18n-tasks-use t('activerecord.attributes.external_pledge.amount')
    # i18n-tasks-use t('activerecord.attributes.external_pledge.source')
    # i18n-tasks-use t('activerecord.attributes.fulfillment.audited')
    # i18n-tasks-use t('activerecord.attributes.fulfillment.check_number')
    # i18n-tasks-use t('activerecord.attributes.fulfillment.date_of_check')
    # i18n-tasks-use t('activerecord.attributes.fulfillment.fulfilled')
    # i18n-tasks-use t('activerecord.attributes.fulfillment.fund_payout')
    # i18n-tasks-use t('activerecord.attributes.fulfillment.gestation_at_procedure')
    # i18n-tasks-use t('activerecord.attributes.fulfillment.procedure_date')
    # i18n-tasks-use t('activerecord.attributes.practical_support.fulfilled')
    @note = @patient.notes.new
    @external_pledge = @patient.external_pledges.new
  end

  def update
    @patient.last_edited_by = current_user

    respond_to do |format|
      format.js do
        respond_to_update_for_js_format
      end
      format.json do
        respond_to_update_for_json_format
      end
    end
  end

  def data_entry
    @patient = Patient.new
  end

  def data_entry_create
    @patient = Patient.new patient_params

    if @patient.save
      flash[:notice] = t('flash.patient_save_success',
                         patient: @patient.name,
                         fund: current_tenant.name)
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

  # preload patient with versions for edit and js format update requests
  def should_preload_patient_with_versions?
    action_name.to_sym == :edit || (action_name.to_sym == :update && !request.format.json?)
  end

  # preload patient minimally for fetch_pledge, download, destroy, and json format update requests
  def should_preload_patient_minimally?
    [:fetch_pledge, :download,
     :destroy].include?(action_name.to_sym) || (action_name.to_sym == :update && request.format.json?)
  end

  def find_patient
    @patient = Patient.includes(versions: [:item, :user])
                      .find params[:id]
  end

  def find_patient_minimal
    @patient = Patient.find params[:id]
  end

  # requests from our autosave using jquery ($(form).submit()) use the js format
  def respond_to_update_for_js_format
    if @patient.update patient_params
      @patient = Patient.includes(versions: [:item, :user]).find(@patient.id) # reload
      flash.now[:notice] = t('flash.patient_info_saved', timestamp: Time.zone.now.display_timestamp)
    else
      error = @patient.errors.full_messages.to_sentence
      flash.now[:alert] = error
    end
  end

  # requests from our autosave using React (via the useFetch hook) use the json format
  def respond_to_update_for_json_format
    if @patient.update patient_params
      @patient.reload
      render json: {
        patient: @patient.reload.as_json,
        flash: {
          notice: t('flash.patient_info_saved', timestamp: Time.zone.now.display_timestamp)
        }
      }, status: :ok
    else
      render json: { flash: { alert: @patient.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  PATIENT_DASHBOARD_PARAMS = [
    :name, :last_menstrual_period_days, :last_menstrual_period_weeks,
    :appointment_date, :primary_phone, :pronouns
  ].freeze

  PATIENT_INFORMATION_PARAMS = [
    :line_id, :age, :race_ethnicity, :language, :voicemail_preference, :textable,
    :city, :state, :county, :zipcode, :other_contact, :other_phone,
    :other_contact_relationship, :employment_status, :income,
    :household_size_adults, :household_size_children, :insurance, :referred_by,
    :procedure_type, :consent_to_survey, special_circumstances: []
  ].freeze

  ABORTION_INFORMATION_PARAMS = [
    :clinic_id, :resolved_without_fund, :referred_to_clinic, :completed_ultrasound,
    :procedure_cost, :ultrasound_cost, :patient_contribution, :naf_pledge, :fund_pledge,
    :fund_pledged_at, :pledge_sent_at, :solidarity, :solidarity_lead, :appointment_time,
    :multiday_appointment
  ].freeze

  FULFILLMENT_PARAMS = [
    fulfillment_attributes: [:id, :fulfilled, :procedure_date, :gestation_at_procedure,
                             :fund_payout, :check_number, :date_of_check, :audited]
  ].freeze

  OTHER_PARAMS = [:shared_flag, :initial_call_date, :pledge_sent, :practical_support_waiver].freeze

  def patient_params
    permitted_params = [].concat(
      PATIENT_DASHBOARD_PARAMS, PATIENT_INFORMATION_PARAMS,
      ABORTION_INFORMATION_PARAMS, OTHER_PARAMS
    )
    permitted_params.concat(FULFILLMENT_PARAMS) if current_user.allowed_data_access?
    params.require(:patient).permit(permitted_params)
  end

  def encrypt_payload(payload)
    encryptor = ActiveSupport::MessageEncryptor.new(ENV.fetch('PLEDGE_GENERATOR_ENCRYPTOR', '0' * 32))
    encrypted = encryptor.encrypt_and_sign(payload)
    encrypted
  end

  def render_csv
    now = Time.zone.now.strftime('%Y%m%d')
    csv_filename = "patient_data_export_#{now}.csv"
    set_headers()

    response.status = 200

    send_stream(filename: "#{csv_filename}") do |y|
      Patient.csv_header.each { |e| y.write e }
      Patient.to_csv.each { |e| y.write e }
      ArchivedPatient.to_csv.each { |e| y.write e }
    end
  end

  def set_headers()
    headers["Content-Type"] = "text/csv"
    headers['X-Accel-Buffering'] = 'no'
    headers["Cache-Control"] = "no-cache"
    headers[Rack::ETAG] = nil # Without this, data doesn't stream
    headers.delete("Content-Length")
  end
end
