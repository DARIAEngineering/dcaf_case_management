# Single-serving controller for setting current line for a user.
class LinesController < ApplicationController
  def new
    if LINES.count == 1
      session[:line] = LINES[0]
      redirect_to authenticated_root_path
    end
  end

  def create
    session[:line] = params[:line]
    redirect_to authenticated_root_path
  end
end
