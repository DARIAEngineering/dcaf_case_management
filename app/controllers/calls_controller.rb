class CallsController < ApplicationController
  before_action :find_pregnancy, only: [:create]

  def create
    @call = @pregnancy.calls.new(call_params)
    @call.creating_user_id = current_user.id
    if @call.save && params[:call][:status] == 'Reached patient'
      redirect_to edit_pregnancy_path(@pregnancy)
    elsif @call.save
      respond_to { |format| format.js }
    else
      flash[:alert] = 'Call failed to save! Please submit the call again.'
      redirect_to root_path
    end
  end

  private

  def call_params
    params.require(:call).permit(:status)
  end

  def find_pregnancy
    @pregnancy = Pregnancy.find params[:id]    
  end
end
