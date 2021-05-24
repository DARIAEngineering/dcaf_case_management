# Create notes associated with patients. 
class NotesController < ApplicationController
  before_action :find_patient, only: [:create]

  def create
    @note = @patient.notes.new note_params
    if @note.save
      @notes = @patient.reload.notes.order(created_at: :desc)
      respond_to do |format|
        format.js
      end
    else
      head :bad_request
    end
  end

  def note_params
    params.require(:note).permit(:full_text)
  end

  def find_patient
    @patient = Patient.find params[:patient_id]
  end
end
