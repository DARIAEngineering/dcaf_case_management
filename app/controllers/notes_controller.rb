class NotesController < ApplicationController
  before_action :find_pregnancy, only: [ :create ]
  before_action :find_note, only: [ :update ]

  def create
    @note = @pregnancy.notes.new(note_params)
    @note.created_by = current_user
    @note.save
    if @note.save
      redirect_to edit_pregnancy_path(@pregnancy), flash: { notice: "Saved new note for #{@pregnancy.patient.name}!" }
    else
      flash[:alert] = 'Note failed to save! Please submit the note again.'
      redirect_to edit_pregnancy_path(@pregnancy)
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

  def find_pregnancy
    @pregnancy = Pregnancy.find params[:pregnancy_id]
  end

  def find_note
    find_pregnancy
    @note = @pregnancy.notes.find params[:id]
  end
end
