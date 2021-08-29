# Single-serving controller for setting current line for a user.
class LinesController < ApplicationController
  def new
    if Line.count == 1
      session[:line] = Line.first.id
      redirect_to authenticated_root_path
    end
    @lines = Line.all
  end

  def create
    line = Line.find(params[:line_id])
    session[:line_id] = line.id
    session[:line_name] = line.name
    redirect_to authenticated_root_path
  end
end
