# Create a non-monetary assistance record for a patient.
class PracticalSupportsController < ApplicationController
  before_action :find_patient, only: [:create]
  before_action :find_support, only: [:update, :destroy]
  rescue_from Mongoid::Errors::DocumentNotFound,
              with: -> { head :not_found }

  def create
    @support = @patient.practical_supports.new practical_support_params
    @support.created_by = current_user
    if @support.save
      flash.now[:notice] = t('flash.patient_info_saved', timestamp: Time.zone.now.display_timestamp)
      @support = @patient.reload.practical_supports.order_by 'created_at desc'
      respond_to { |format| format.js }
    else
      flash.now[:alert] = "Practical support failed to save: #{@support.errors.full_messages.to_sentence}"
      respond_to do |format|
        format.js { render partial: 'layouts/flash_messages', status: :bad_request }
      end
    end
  end

  def update
    if @support.update practical_support_params
      flash.now[:notice] = t('flash.patient_info_saved', timestamp: Time.zone.now.display_timestamp)
      respond_to { |format| format.js }
    else
      flash.now[:alert] = "Practical support failed to save: #{@support.errors.full_messages.to_sentence}"
      respond_to do |format|
        format.js { render partial: 'layouts/flash_messages', status: :bad_request }
      end
    end
  end

  def destroy
    @support.destroy
    respond_to { |format| format.js }
  end

  private

  def practical_support_params
    params.require(:practical_support)
          .permit(:confirmed, :source, :support_type)
  end

  def find_patient
    @patient = Patient.find params[:patient_id]
  end

  def find_support
    find_patient
    @support = @patient.practical_supports.find params[:id]
  end
end
