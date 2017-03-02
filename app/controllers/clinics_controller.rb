class ClinicsController < ApplicationController
  before_action :confirm_admin_user
  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :bad_request }

  def index
    @clinics = Clinic.all
  end

  def create
    clinic = Clinic.new clinic_params
    if clinic.save
      redirect_to clinics_path
    end
  end

  def update
    clinic = Clinic.find params[:id]
    if clinic.save
      head :ok
    else
      head :bad_request
    end
  end

  private

  def clinic_params
  end
end
