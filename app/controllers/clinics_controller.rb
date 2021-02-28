# Clinic-related functionality.
class ClinicsController < ApplicationController
  before_action :confirm_admin_user
  before_action :find_clinic, only: [:update, :edit]
  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :bad_request }

  def index
    @clinics = Clinic.all.sort_by { |c| [c.name] }
    respond_to do |format|
      format.html
    end
  end

  def create
    @clinic = Clinic.new clinic_params
    if @clinic.save
      flash[:notice] = t('flash.clinic_created', clinic: @clinic.name)
      redirect_to clinics_path
    else
      flash[:alert] = t('flash.error_saving_clinic', error: @clinic.errors.full_messages.to_sentence)
      render 'new'
    end
  end

  def new
    # i18n-tasks-use t('activerecord.attributes.clinic.phone')
    # i18n-tasks-use t('activerecord.attributes.clinic.fax')
    # i18n-tasks-use t('activerecord.attributes.clinic.active')
    @clinic = Clinic.new
  end

  def edit; end

  def update
    if @clinic.update clinic_params
      flash[:notice] = t('flash.clinic_details_updated')
      redirect_to clinics_path
    else
      flash[:alert] = t('flash.error_saving_clinic_details', error: @clinic.errors.full_messages.to_sentence)
      render 'edit'
    end
  end

  private

  def find_clinic
    @clinic = Clinic.find params[:id]
  end

  def clinic_params
    clinic_params = [:name, :street_address, :city, :state, :zip,
                     :phone, :fax, :active, :accepts_naf, :accepts_medicaid,
                     :gestational_limit]
    cost_params = (5..30).map { |i| "costs_#{i}wks".to_sym }

    params.require(:clinic).permit(
      clinic_params.concat(cost_params)
    )
  end
end
