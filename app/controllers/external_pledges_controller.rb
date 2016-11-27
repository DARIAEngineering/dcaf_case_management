# Create a pledge. Not currently utilized
class ExternalPledgesController < ApplicationController
  before_action :find_patient, only: [:create]
  before_action :find_pledge, only: [:update]

  def create
    @pledge = @patient.pledges.new(pledge_params)
    @pledge.created_by = current_user
    # fail
    if @pledge.save
      redirect_to edit_patient_path(@patient),
                  flash: { notice: 'Saved new pledge for ' \
                                   "#{@patient.name}!" }
    else
      flash[:alert] = 'pledge failed to save! Please submit the pledge again.'
      redirect_to edit_patient_path(@patient)
    end
  end

  def update
    if @pledge.update_attributes pledge_params
      respond_to { |format| format.js }
    else
      head :bad_request
    end
  end

  private

  def pledge_params
    params.require(:pledge).permit(:pledge_type, :amount,
                                   :other_pledge_identifier,
                                   :sent, :sent_by, :paid, :paid_date)
  end

  def find_patient
    @patient = Patient.find params[:patient_id]
  end

  def find_pledge
    find_patient
    @pledge = @patient.pledges.find params[:id]
  end
end
