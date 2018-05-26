# Controller for managing a user's call list.
class CallListsController < ApplicationController
  before_action :retrieve_patients, only: [:add_patient, :remove_patient]
  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :not_found }

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
    current_user.clear_call_list
    respond_to do |format|
      format.js { render template: 'users/refresh_patients', layout: false }
    end
  end

  def reorder_call_list
    # TODO: fail if anything is not a BSON id
    current_user.reorder_call_list params[:order] # TODO: adjust to payload
    # respond_to { |format| format.js }
    head :ok
  end

  private

  def retrieve_patients
    @patient = Patient.find params[:id]
    @urgent_patient = Patient.where(urgent_flag: true)
  end
end
