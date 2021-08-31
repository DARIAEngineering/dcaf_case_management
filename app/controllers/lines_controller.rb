# Single-serving controller for setting current line for a user.
class LinesController < ApplicationController
  def new
    if Line.count == 1
      set_line_session(Line.first)
      redirect_to authenticated_root_path
    end
    @lines = Line.all
  end

  def create
    set_line_session(Line.find(params[:id]))
    redirect_to authenticated_root_path
  end

  private

  def set_line_session(line)
    session[:line_id] = line.id
    session[:line_name] = line.name
  end
end
