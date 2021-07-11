# Controller pertaining to accountant functions, usually fulfillments.
class AccountantsController < ApplicationController
  before_action :confirm_data_access, only: [:index]
  before_action :confirm_data_access_async, only: [:search, :edit]
  before_action :find_patient, only: [:edit]

  def index
    @patients = paginate_results(pledged_patients)
  end

  def search
    have_search = params[:search].present?
    have_clinic = params[:clinic_id].present?

    if have_search || have_clinic
      partial = pledged_patients

      partial = partial.where(clinic_id: params[:clinic_id]) if have_clinic
      partial = partial.search(params[:search], search_limit: nil) if have_search

      results = partial
    else
      results = pledged_patients
    end

    @patients = paginate_results results

    respond_to { |format| format.js }
  end

  def edit
    # This is a cheater method that populates the fulfillment partial into a
    # modal via ajax.
    respond_to { |format| format.js }
  end

  private

  def paginate_results(results)
    Kaminari.paginate_array(results)
            .page(params[:page])
            .per(25)
  end

  def pledged_patients
    Patient.where(pledge_sent: true)
           .includes(:clinic)
           .includes(:fulfillment)
           .order(pledge_sent_at: :desc)
  end

  def find_patient
    @patient = Patient.find params[:id]
  end
end
