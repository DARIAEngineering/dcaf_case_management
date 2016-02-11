class CallsController < ApplicationController

  def create
    patient = Patient.find(params[:id])
    @call = patient.calls.new(params[:status])
		if @call.save
			redirect_to root_path
		end
  end

end
