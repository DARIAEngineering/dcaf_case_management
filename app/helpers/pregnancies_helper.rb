module PregnanciesHelper
  def weeks_options
    (1..30).map { |i| [pluralize(i, 'week'), i] }
  end

  def days_options
    (0..6).map { |i| ["#{i} days", i] }
  end
end
