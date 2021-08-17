# Methods relating to management of a user's call list
module CallListable
  extend ActiveSupport::Concern

  # Someone is recently called if:
  # someone has a call from the current_user
  # that is less than 8 hours old,
  # AND they would otherwise be in the call list
  # (e.g. assigned to current line and in user.patients)
  def call_list_patients(line)
    ordered_patients(line).reject { |x| recently_called_by_user? x }
  end

  def recently_called_patients(line)
    ordered_patients(line).select { |x| recently_called_by_user? x }
  end

  def recently_reached_patients(line)
    ordered_patients(line).select { |x| recently_reached_by_user? x }
  end

  def add_patient(patient)
    present_calls = call_list_entries.where(line: patient.line).to_a
    return if present_calls.map { |x| x.patient_id.to_s }.include? patient.id.to_s

    # Increment existing call list entries and then insert the new one.
    present_calls.each do |entry|
      entry.update order_key: entry.order_key + 1
    end
    call_list_entries.create! patient: patient,
                              line: patient.line,
                              order_key: 0
    reload
  end

  def remove_patient(patient)
    call_list_entries.find_by!(patient_id: patient.id).destroy
    reload
  end

  def reorder_call_list(order, line)
    current_entries = call_list_entries.includes(:patient).where(line: line).to_a
    order.each_with_index do |pt, i|
      current = current_entries.find { |x| x.patient_id.to_s == pt }
      current.update order_key: i
    end
    reload
  end

  TIME_BEFORE_INACTIVE = 2.weeks

  def clean_call_list_between_shifts
    # current_sign_in_at is a devise field set to the user's last login
    if current_sign_in_at.present? &&
       current_sign_in_at < Time.zone.now - TIME_BEFORE_INACTIVE
      clear_call_list(LINES)
    else
      ids_for_destroy = recently_reached_patients(LINES).map { |x| x.id.to_s }
      call_list_entries.where(patient_id: ids_for_destroy).destroy_all
    end
    reload
  end

  def clear_call_list(line)
    call_list_entries.where(line: line).destroy_all
  end

  private

  def ordered_patients(line)
    # n+1 join here
    call_list_entries.includes(patient: [:calls, :fulfillment])
                     .where(line: line)
                     .order(order_key: :asc)
                     .map(&:patient)
                     .reject(&:nil?)
  end

  def recently_reached_by_user?(patient)
    patient.calls.any? do |call|
      call.created_by_id == id && call.recent? && call.reached_patient?
    end
  end

  def recently_called_by_user?(patient)
    patient.calls.any? { |call| call.created_by_id == id && call.recent? }
  end
end
