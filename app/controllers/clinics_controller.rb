class ClinicsController < ApplicationController
  before_action :confirm_admin_user
  before_action :find_clinic, only: [:update, :edit, :destroy]
  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :bad_request }

  def index
    @clinics = Clinic.all
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

  def edit
  end

  def update
    if @clinic.update_attributes clinic_params
      flash[:notice] = 'Successfully updated clinic details'
    else
      flash[:alert] = 'Error saving clinic details'
    end
    redirect_to clinics_path
  end

  def find_clinic
    @clinic = Clinic.find params[:id]
  end

  # def destroy
  # end

  private

  def clinic_params
    params.require(:clinic).permit(
      :name, :street_address, :city, :state, :zip,
      :phone, :accepts_naf, :gestational_limit,
      :costs_9wks, :costs_12wks, :costs_18wks,
      :costs_24wks, :costs_30wks
    )
  end
end
