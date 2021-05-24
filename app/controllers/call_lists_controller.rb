# Controller for managing a user's call list.
class CallListsController < ApplicationController
  include LinesHelper

  before_action :retrieve_patients, only: [:add_patient, :remove_patient]
  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

  def add_patient
    current_user.add_patient @patient
    respond_to do |format|
      format.js { render template: 'users/refresh_patients', layout: false }
    end
  end

  def remove_patient
    current_user.remove_patient @patient
    respond_to do |format|
      format.js { render template: 'users/refresh_patients', layout: false }
    end
  end

  def clear_current_user_call_list
    current_user.clear_call_list current_line
    respond_to do |format|
      format.js { render template: 'users/refresh_patients', layout: false }
    end
  end

  def reorder_call_list
    current_user.reorder_call_list params[:order], current_line
    head :ok
  end

  private

  def retrieve_patients
    @patient = Patient.find params[:id]
  end
end
