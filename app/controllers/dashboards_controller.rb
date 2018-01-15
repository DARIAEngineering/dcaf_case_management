# Controller for rendering the home view and patient search.
class DashboardsController < ApplicationController
  include LinesHelper

  before_action :pick_line_if_not_set, only: [:index, :search]

  def index
    @urgent_patients = Patient.urgent_patients(current_line)
  end

  def search
    @results = Patient.search params[:search],
                              [current_line.try(:to_sym) || lines]

    @patient = Patient.new
    @today = Time.zone.today.to_date
    @phone = searched_for_phone?(params[:search]) ? params[:search] : ''
    @name = searched_for_name?(params[:search]) ? params[:search] : ''

    respond_to { |format| format.js }
  end

  def budget_bar
    expenditures = Patient.pledged_status_summary
    budget_bar_ceiling = [1350,
                          expenditures.values.flatten.map { |x| x[:fund_pledge] }.inject(:+)].max

    render partial: 'dashboards/budget_bar', locals: { expenditures: expenditures,
                                                       limit: budget_bar_ceiling }
  end

  private

  def searched_for_phone?(query)
    !/[a-z]/i.match query
  end

  def searched_for_name?(query)
    /[a-z]/i.match query
  end

  def pick_line_if_not_set
    redirect_to new_line_path if session[:line].blank?
  end
end
