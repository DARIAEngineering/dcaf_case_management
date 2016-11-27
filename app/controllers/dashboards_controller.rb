# Basically just search and the home view
class DashboardsController < ApplicationController
  include LinesHelper

  before_action :pick_line_if_not_set, only: [:index, :search]

  def index
    @urgent_patients = Patient.urgent_patients
    @expenditures = Patient.pledged_status_summary
  end

  def search
    @results = Patient.search params[:search], [current_line.to_sym]

    @patient = Patient.new
    @today = Time.zone.today.to_date
    @phone = searched_for_phone?(params[:search]) ? params[:search] : ''
    @name = searched_for_name?(params[:search]) ? params[:search] : ''

    respond_to { |format| format.js }
  end

  private

  def searched_for_phone?(query)
    !/[a-z]/i.match query
  end

  def searched_for_name?(query)
    /[a-z]/i.match query
  end

  def pick_line_if_not_set
    redirect_to new_line_path unless session[:line].present?
  end
end
