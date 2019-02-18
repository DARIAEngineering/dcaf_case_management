# Create a non-monetary assistance record for a patient.
class PracticalSupportsController < ApplicationController
  before_action :find_patient, only: [:create]
  before_action :find_support, only: [:update, :destroy]
  rescue_from Mongoid::Errors::DocumentNotFound,
              with: -> { head :not_found }

  def create
    @support = @patient.external_pledges.new external_pledge_params
    @support.created_by = current_user
    if @support.save
      @support = @patient.reload.external_pledges.order_by 'created_at desc'
      respond_to { |format| format.js }
    else
      head :bad_request
    end
  end

  def update
    if @support.update practical_support_params
      respond_to { |format| format.js }
    else
      head :bad_request
    end
  end

  def destroy
    @support.destroy
    respond_to { |format| format.js }
  end

  private

  def practical_support_params
    params.require(:practical_support).permit(:stuff)
  end

  def find_patient
    @patient = Patient.find params[:patient_id]
  end

  def find_pledge
    find_patient
    @support = @support.external_pledges.find params[:id]
  end    
end
