# Create method for calls, plus triggers for modal behavior
class CallsController < ApplicationController
  before_action :find_patient, only: [:create, :destroy]

  def create
    @call = @patient.calls.new call_params
    @call.created_by = current_user
    if call_saved_and_patient_reached @call, params
      redirect_to edit_patient_path @patient
    elsif @call.save
      respond_to { |format| format.js }
    else
      head :bad_request
    end
  end

  def destroy
    call = @patient.calls.find params[:id]
    if call.created_by != current_user || !call.recent?
      head :forbidden
    elsif call.destroy
      respond_to { |format| format.js }
    else
      head :bad_request
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
