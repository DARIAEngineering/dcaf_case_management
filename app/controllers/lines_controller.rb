# Single-serving controller for setting current line for a user.
class LinesController < ApplicationController
  def new; end

  def create
    session[:line] = params[:line]
    redirect_to authenticated_root_path
  end
end
