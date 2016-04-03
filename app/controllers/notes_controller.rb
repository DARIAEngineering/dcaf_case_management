class NotesController < ApplicationController
  before_action :find_pregnancy, only: [:create]

  def create
    @note = @pregnancy.notes.new(note_params)
    if @call.save
      redirect_to edit_pregnancy_path(@pregnancy)
      # respond_to { |format| format.js }
    else
      flash[:alert] = 'Note failed to save! Please submit the note again.'
      redirect_to root_path
    end
  end

  def update
  end

  private

    def note_params
      params.require(:note).permit(:notes)
    end

    def find_pregnancy
      @pregnancy = Pregnancy.find params[:id]
    end
end
