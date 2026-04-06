# Create a pledge from a non-fund organization
class ExternalPledgesController < ApplicationController
  before_action :find_patient, only: [:create]
  before_action :find_pledge, only: [:update, :destroy]
  rescue_from ActiveRecord::RecordNotFound,
              with: -> { head :not_found }

  def create
    @pledge = @patient.external_pledges.new external_pledge_params
    if @pledge.save
      @pledge = @patient.reload.external_pledges.order(created_at: :desc)
      respond_to do |format|
        format.turbo_stream
        format.js
      end
    else
      head :bad_request
    end
  end

  def update
    if @pledge.update external_pledge_params
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
    @pledge.update active: false
    head :ok
  end

  private

  def external_pledge_params
    params.require(:external_pledge).permit(:source, :amount)
  end

  def find_patient
    @patient = Patient.find params[:patient_id]
  end

  def find_pledge
    find_patient
    @pledge = @patient.external_pledges.find params[:id]
  end
end
