module LinesHelper
  def lines
    ENV['LINES'].present? ? split_and_strip(ENV['LINES']) : %w(DC MD VA)
  end

  def current_line
    "Line: #{session[:line]}" if session[:line]
  end

  private

  def split_and_strip(string)
    string.split(',').map(&:strip)
  end
end
