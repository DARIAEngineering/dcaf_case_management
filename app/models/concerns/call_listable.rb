# Methods relating to management of a user's call list
module CallListable
  extend ActiveSupport::Concern

  # Someone is recently called if:
  # someone has a call from the current_user
  # that is less than 8 hours old,
  # AND they would otherwise be in the call list
  # (e.g. assigned to current line and in user.patients)

  def recently_called_patients(line)
    patients.where(line: line)
            .select { |patient| recently_called_by_user? patient }
  end

  def call_list_patients(line)
    patients.where(line: line)
            .reject { |patient| recently_called_by_user? patient }
  end

  def add_patient(patient)
    patients << patient
    if call_order
      reorder_call_list(call_order.unshift(patient.id.to_s))
    else
      reorder_call_list([patient.id.to_s])
    end
    reload
  end

  def remove_patient(patient)
    patients.delete patient
    reload
  end

  def reorder_call_list(order)
    update call_order: order
    save
    reload
  end

  def ordered_patients(line)
    return call_list_patients(line) unless call_order
    ordered_patients = call_list_patients(line).sort_by do |patient|
      call_order.index(patient.id.to_s) || call_order.length
    end
    ordered_patients
  end

  TIME_BEFORE_INACTIVE = 2.weeks

  def clean_call_list_between_shifts
    # current_sign_in_at is a devise field set to the user's last login
    if current_sign_in_at.present? &&
       current_sign_in_at < Time.zone.now - TIME_BEFORE_INACTIVE
      clear_call_list
    else
      patients.each { |p| patients.delete(p) if recently_reached_by_user?(p) }
    end
  end

  def clear_call_list
    patients.clear
    save
  end

  private

  def recently_reached_by_user?(patient)
    patient.calls.any? do |call|
      call.created_by_id == id && call.recent? && call.reached?
    end
  end

  def recently_called_by_user?(patient)
    patient.calls.any? { |call| call.created_by_id == id && call.recent? }
  end
end
