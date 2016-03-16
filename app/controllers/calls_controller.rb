class CallsController < ApplicationController
  def create
    p = Pregnancy.find(params[:id])
    @call = p.calls.new(call_params)
		if @call.save && params[:call][:status] == "Reached patient"
      redirect_to edit_pregnancy_path(p)
    elsif @call.save
      respond_to { |format| format.js }
    else
      flash[:alert] = "Call failed to save! Please submit the call again."
      redirect_to root_path
		end
  end

  private

	def call_params
		params.require(:call).permit(:status)
	end
end
