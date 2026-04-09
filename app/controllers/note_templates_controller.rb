class NoteTemplatesController < ApplicationController
  def index
    @templates = NoteTemplate.available_to(current_user)
    respond_to do |format|
      format.json { render json: @templates.as_json(only: [:id, :name, :full_text, :user_id]) }
    end
  end

  def create
    @template = NoteTemplate.new(template_params)
    @template.user = current_user unless current_user.admin? && params[:note_template][:fund_level] == '1'

    if @template.save
      flash[:notice] = t('flash.note_template_saved', default: 'Note template saved.')
    else
      flash[:alert] = @template.errors.full_messages.to_sentence
    end
    redirect_back fallback_location: authenticated_root_path
  end

  def destroy
    @template = NoteTemplate.find(params[:id])
    # Users can only delete their own templates; admins can delete fund-level ones
    if @template.user_id == current_user.id || (current_user.admin? && @template.user_id.nil?)
      @template.destroy
      flash[:notice] = t('flash.note_template_deleted', default: 'Note template deleted.')
    else
      flash[:alert] = t('flash.not_authorized', default: 'Not authorized.')
    end
    redirect_back fallback_location: authenticated_root_path
  end

  private

  def template_params
    params.require(:note_template).permit(:name, :full_text)
  end
end
