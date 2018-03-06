# Create method for calls, plus triggers for modal behavior
class CallsController < ApplicationController
  before_action :find_can_call, only: [:new, :create, :destroy]

  def create
    @call = @can_call.calls.new call_params
    @call.created_by = current_user
    if call_saved_and_patient_reached @call, params
      redirect_to @can_call
    elsif @call.save
      respond_to { |format| format.js }
    else
      head :bad_request
    end
  end

  def new
    respond_to do |format|
      format.js
    end
  end

  def destroy
    call = @can_call.calls.find params[:id]
    if call.created_by != current_user || !call.recent?
      head :forbidden
    elsif call.destroy
      respond_to { |format| format.js }
    else
      head :bad_request
    end
  end

  private

  def call_params
    params.require(:call).permit(:status)
  end

  def find_can_call
    resource, id = request.path.split('/')[1,2]
    @can_call = resource.singularize.classify.constantize.find(id)
  end

  def call_saved_and_patient_reached(call, params)
    call.save && params[:call][:status] == 'Reached patient'
  end
end
