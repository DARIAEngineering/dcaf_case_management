# Clinic-related functionality.
class ClinicsController < ApplicationController
  before_action :confirm_admin_user, except: [:index]
  before_action :find_clinic, only: [:update, :edit]
  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :bad_request }

  def index
    @clinics = Clinic.all.sort_by { |c| [c.name] }
    respond_to do |format|
      format.html
      format.json { render json: @clinics }
    end
  end

  def create
    @clinic = Clinic.new clinic_params
    if @clinic.save
      flash[:notice] = "#{@clinic.name} created!"
      redirect_to clinics_path
    else
      flash[:alert] = 'Errors prevented this clinic from being saved: ' \
                      "#{@clinic.errors.full_messages.to_sentence}"
      render 'new'
    end
  end

  def new
    @clinic = Clinic.new
  end

  def edit; end

  def update
    if @clinic.update_attributes clinic_params
      flash[:notice] = 'Successfully updated clinic details'
      redirect_to clinics_path
    else
      flash[:alert] = 'Error saving clinic details: ' \
                      "#{@clinic.errors.full_messages.to_sentence}"
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
