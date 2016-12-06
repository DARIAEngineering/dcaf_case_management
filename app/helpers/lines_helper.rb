module LinesHelper
  def lines
    LINES
  end

  def current_line_display
    "Line: #{session[:line]}" if session[:line]
  end

  def current_line
    session[:line]
  end
end
