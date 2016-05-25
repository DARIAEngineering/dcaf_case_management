module PregnanciesHelper
  def weeks_options
    (1..30).map { |i| [pluralize(i, 'week'), i] }
  end

  def days_options
    (0..6).map { |i| ["#{i} days", i] }
  end

  # ticket 241 recently called criteria:
  # someone has a call from the current_user
  # that is less than 8 hours old,
  # AND they would otherwise be in the call list

  def call_list_pregnancies
    current_user.pregnancies.reject { |p| recently_called_by_user?(p) }
  end

  def recently_called_pregnancies
    current_user.pregnancies.select { |p| recently_called_by_user?(p) }
  end

  def recently_called_by_user?(pregnancy)
    pregnancy.calls.any? { |c| c.created_by_id == current_user.id && recent?(c) }
  end

  def recent?(call)
    time_of_call = call.updated_at
    time_of_call > 8.hours.ago ? true : false
  end
end
