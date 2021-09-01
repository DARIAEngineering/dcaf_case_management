# Convenience function for displaying lines around the app.
module LinesHelper
  # This returns an array of the available service lines, defined in
  # `config/initializers/env_var_constants.rb`.
  # Defaults to [:DC, :MD, :VA]
  # def lines
  #   LINES
  # end

  def current_line_display
    content_tag :li do
      content_tag :span, t('navigation.current_line.helper') + ": #{session[:line_name]}",
                         class: 'nav-link navbar-text-alt'
    end if session[:line_name]
  end

  def current_line
    Line.find(session[:line_id])
  end

  def current_line_name
    session[:line_name]
  end

end
