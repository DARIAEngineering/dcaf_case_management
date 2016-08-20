class CallsController < ApplicationController
  before_action :find_patient, only: [:create]

  def create
    @call = @patient.calls.new call_params
    @call.created_by = current_user
    if call_saved_and_patient_reached @call, params
      redirect_to edit_patient_path @patient
    elsif @call.save
      respond_to { |format| format.js }
    else
      flash[:alert] = 'Call failed to save! Please submit the call again.'
      redirect_to root_path
    end
  end

  private

  def call_params
    params.require(:call).permit(:status)
  end

  def find_patient
    @patient = Patient.find params[:patient_id]
  end

  def call_saved_and_patient_reached(call, params)
    call.save && params[:call][:status] == 'Reached patient'
  end
end
