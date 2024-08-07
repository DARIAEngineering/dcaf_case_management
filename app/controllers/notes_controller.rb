# Create notes associated with patients. 
class NotesController < ApplicationController
  before_action :find_object, only: [:create]

  def create
    @note = @object.notes.new note_params
    if @note.save
      @notes = @object.reload.notes.order(created_at: :desc)
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

  def find_object
    @object = PracticalSupport.find params[:practical_support_id] if params[:practical_support_id]
    @object = Patient.find params[:patient_id] if params[:patient_id]
  end
end
