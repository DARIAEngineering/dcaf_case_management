module LinesHelper
  def lines
    LINES
  end

  def current_line_display
    "Your current line: #{session[:line]}" if session[:line]
  end

  def current_line
    session[:line]
  end
end
