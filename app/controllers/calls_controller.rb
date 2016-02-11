class CallsController < ApplicationController

  def create
    c = Case.find(params[:id])
    @call = c.calls.new(status: params[:status])
		if @call.save
			redirect_to root_path
		end
  end

end
