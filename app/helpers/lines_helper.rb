# Convenience function for displaying lines around the app.
module LinesHelper
  def current_line_display
    content_tag :li do
      content_tag :span, t('navigation.current_line.helper') + ": #{current_line.name}",
                         class: 'nav-link navbar-text-alt'
    end if session[:line_id]
  end

  def current_line
    Line.find_by_id session[:line_id]
  end
end
