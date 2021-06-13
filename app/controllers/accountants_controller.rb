# Controller pertaining to accountant functions, usually fulfillments.
class AccountantsController < ApplicationController
  before_action :confirm_data_access, only: [:index]
  before_action :confirm_data_access_async, only: [:search, :edit]
  before_action :find_patient, only: [:edit]

  def index
    patients = pledged_patients.includes(:clinic)
    @patients = paginate_results(patients)

    @entry_name = t 'common.patient'
  end

  def search
    index

    @results = if params[:search].present?
                 pledged_patients.search(params[:search])
               else
                 pledged_patients
               end

    @results = paginate_results @results

    if @results.length != @patients.length
      extra_display = t('accountants.extra_count', count: @patients.length,
                                                   entry: 'patient'.pluralize(@patients.length))
      @result_count_extra = " (#{extra_display})"
      @entry_name = t 'accountants.results'
    end

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
    Patient.where(pledge_sent: true,
                  :initial_call_date.gte => 6.months.ago)
           .order(pledge_sent_at: :desc)
  end

  def find_patient
    @patient = Patient.find params[:id]
  end
end
