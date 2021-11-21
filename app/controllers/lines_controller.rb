# Single-serving controller for setting current line for a user.
class LinesController < ApplicationController
  def new
    @lines = ActsAsTenant.current_tenant.lines
    if @lines.count == 0
      raise Exceptions::NoLinesForFundError
    end

    if @lines.count == 1
      set_line_session @lines.first
      redirect_to authenticated_root_path
    end
    @lines
  end

  def create
    line = Line.find params[:line_id]
    session[:line_id] = line.id
    redirect_to authenticated_root_path
  end

  private

  def set_line_session(line)
    session[:line_id] = line.id
  end
end
