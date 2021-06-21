# Controller pertaining to accountant functions, usually fulfillments.
class AccountantsController < ApplicationController
  before_action :confirm_data_access, only: [:index]
  before_action :confirm_data_access_async, only: [:search, :edit]
  before_action :find_patient, only: [:edit]

  def index
    generate_base_patients
  end

  def search
    generate_base_patients
      
    have_search = params[:search].present?
    have_clinic = params[:clinic_id].present?

    if have_search || have_clinic
      partial = pledged_patients

      partial = partial.where(clinic_id: params[:clinic_id]) if have_clinic
      partial = partial.search(params[:search], search_limit: nil) if have_search

      @results = partial
    else
      @results = pledged_patients.where(initial_call_date: 6.months.ago..)
    end
  
    @results = paginate_results @results

    if @results.length != @patients.length
      extra_display = t('accountants.extra_count', count: @patients.length,
                                                   entry: t('common.patient').pluralize(@patients.length))
      @result_count_extra = " (#{extra_display})"
      @entry_name = t('accountants.results')
    end

    respond_to { |format| format.js }
  end

  def edit
    # This is a cheater method that populates the fulfillment partial into a
    # modal via ajax.
    respond_to { |format| format.js }
  end

  private

  def generate_base_patients
    patients = pledged_patients.includes(:clinic)
    @patients = paginate_results(patients)

    @entry_name = t('common.patient')
  end

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
