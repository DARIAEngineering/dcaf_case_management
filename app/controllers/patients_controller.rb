class PatientsController < ApplicationController
  def create
    @patient = Patient.new(patient_params)
    if @patient.save
      redirect_to root_path
    else
      # TODO: flash validations in view. Danger alert message is fine for now
      redirect_to root_path
    end
  end

  private

  def patient_params
    params.require(:patient).permit(:name, :primary_phone, :secondary_phone)
  end
end
