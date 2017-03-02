class ClinicsController < ApplicationController
  before_action :confirm_admin_user
  before_action :find_clinic, only: [:update, :destroy]
  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :bad_request }

  def index
    @clinics = Clinic.all
  end

  def create
    @clinic = Clinic.new clinic_params
    if @clinic.save
      redirect_to clinics_path # flash good
    else
      redirect_to clinics_path # flash bad
    end
  end

  def new
    @clinic = Clinic.new
  end

  def update
    clinic = Clinic.find params[:id]
    if clinic.save
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
  end

  private

  def clinic_params
  end
end
