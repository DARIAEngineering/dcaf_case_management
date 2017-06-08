# Create notes associated with patients. 
class NotesController < ApplicationController
  before_action :find_patient, only: [:create]
  before_action :find_note, only: [:update]

  def create
    @note = @patient.notes.new note_params
    @note.created_by = current_user
    if @note.save
      @notes = @patient.reload.notes.order_by 'created_at desc'
      respond_to do |format|
        format.js
      end
    else
      head :bad_request
    end
  end

  def update
    if @note.update_attributes note_params
      respond_to { |format| format.js }
    else
      head :bad_request
    end
  end

  private

  def note_params
    params.require(:note).permit(:full_text)
  end

  def find_patient
    @patient = Patient.find params[:patient_id]
  end

  def find_note
    find_patient
    @note = @patient.notes.find params[:id]
  end
end
