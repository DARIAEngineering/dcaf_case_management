class PregnanciesController < ApplicationController
  before_action :find_pregnancy, only: [:edit, :update]
  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { redirect_to root_path }

  def create
    @pregnancy = Pregnancy.new pregnancy_params
    @pregnancy.created_by = @pregnancy.patient.created_by = current_user
    if @pregnancy.save
      flash[:notice] = 'A new patient has been successfully saved'
    else
      flash[:alert] = 'An error prevented this patient from being saved'
    end
    redirect_to root_path
  end

  def edit
    @note = Note.new
  end

  def update
    if @pregnancy.update_attributes pregnancy_params
      redirect_to edit_pregnancy_path(@pregnancy),
                  flash: { notice: "Saved info for #{@pregnancy.patient.name}!" }
    else
      head :bad_request
      # redirect_to edit_pregnancy_path(@pregnancy), flash: { alert: "Error saving info for #{@pregnancy.patient.name}!" }
    end

    # TODO: respond_to format.js eventually
  end

  private

  def find_pregnancy
    @pregnancy = Pregnancy.find params[:id]
  end

  def pregnancy_params
    params.require(:pregnancy).permit(
      # fields in create
      :voicemail_ok, :initial_call_date,
      # fields in dashboard
      :status, :last_menstrual_period_days, :last_menstrual_period_weeks, :appointment_date,
      # fields in abortion info
      :procedure_cost,
      # fields in patient info
      :age, :race_ethnicity, :city, :state, :zip, :employment_status, :income, :household_size, :insurance, :referred_by,
      # associated
      clinic: [:id, :name, :street_address_1, :street_address_2, :city, :state, :zip],
      patient: [:id, :name, :primary_phone, :secondary_person, :secondary_phone]
    )
  end
end
