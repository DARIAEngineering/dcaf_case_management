module ApplicationHelper
  def lines
    ENV['AVAILABLE_LINES'] || %w(DC MD VA)
  end
end
