# Controller pertaining to accountant functions, usually fulfillments.
class AccountantsController < ApplicationController
  before_action :confirm_data_access, only: [:index]
  before_action :confirm_data_access_async, only: [:search, :edit]
  before_action :find_patient, only: [:edit]

  def index
    @patients = pledged_base.page(params[:page] || 1)
    @patients = @patients.where(clinic_id: params[:clinic_id]) if params[:clinic_id].present?
    @patients = @patients.search(params[:search]) if params[:search].present?
    @patients = @patients.page(params[:page] || 1)
  end

  # def search
  #   @patients = pledged_base

  #   # @patients = paginate_results results

  #   respond_to { |format| format.js }
  # end

  def edit
    # This is a cheater method that populates the fulfillment partial into a
    # modal via ajax.
    respond_to { |format| format.js }
  end

  private

  def pledged_base
    Patient.where(pledge_sent: true)
           .includes(:clinic)
           .includes(:fulfillment)
           .order(pledge_sent_at: :desc)
  end

  def find_patient
    @patient = Patient.find params[:id]
  end
end
