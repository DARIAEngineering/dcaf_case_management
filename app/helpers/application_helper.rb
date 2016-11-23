module ApplicationHelper
  def lines
    %w(DC MD VA) # TODO: Env var this
  end

  def current_line
    "Line: #{session[:line]}" if session[:line]
  end
end
