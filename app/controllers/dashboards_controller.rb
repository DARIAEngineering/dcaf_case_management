# Controller for rendering the home view and patient search.
class DashboardsController < ApplicationController
  include LinesHelper
  include BudgetBarCalculable

  before_action :pick_line_if_not_set, only: [:index, :search]

  def index
    @urgent_patients = eager_loaded_patients.urgent_patients(current_line)
    @unconfirmed_support_patients = eager_loaded_patients.unconfirmed_practical_support(current_line)
  end

  def search
    if params[:search].present?
      @results = eager_loaded_patients.search params[:search],
                                              lines: [current_line || Line.all]
    else
      @results = []
    end

    @patient = Patient.new
    @today = Time.zone.today.to_date
    @phone = searched_for_phone?(params[:search]) ? params[:search] : ''
    @name = searched_for_name?(params[:search]) ? params[:search] : ''

    respond_to { |format| format.js }
  end

  def budget_bar
    # We call these by interpolation in the view; these comments are to let i18n-health know we're using them
    # i18n-tasks-use t('dashboard.budget_bar.pledged_item')
    # i18n-tasks-use t('dashboard.budget_bar.sent_item')
    # i18n-tasks-use t('dashboard.budget_bar.pledged_report')
    # i18n-tasks-use t('dashboard.budget_bar.sent_report')
    render partial: 'dashboards/budget_bar',
           locals: budget_bar_calculations(current_line)
  end

  private

  def eager_loaded_patients
    Patient.includes([:calls, :fulfillment, :practical_supports])
  end

  def searched_for_phone?(query)
    !/[a-z]/i.match query
  end

  def searched_for_name?(query)
    /[a-z]/i.match query
  end

  def pick_line_if_not_set
    redirect_to new_line_path if session[:line_id].blank?
  end
end
