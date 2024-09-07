# Convenience function for displaying lines around the app.
module LinesHelper
  def current_line_display
    return if !session[:line_id]

    # If multiple lines, link to the switcher
    if Line.count > 2
      return content_tag :li do
        link_to t('navigation.current_line.helper') + ": #{current_line.name}",
                new_line_path,
                class: 'nav-link navbar-text-alt'
      end
    end

    # Otherwise just display the content
    content_tag :li do
      content_tag :span, t('navigation.current_line.helper') + ": #{current_line.name}",
                         class: 'nav-link navbar-text-alt'
    end
  end

  def current_line
    Line.find_by_id session[:line_id]
  end
end
