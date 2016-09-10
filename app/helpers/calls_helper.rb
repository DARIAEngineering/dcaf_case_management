module CallsHelper
  def display_voicemail_link_with_warning(patient)
    if patient.voicemail_preference == :no
      no_voicemail_notifier
    elsif patient.voicemail_preference == :yes
      voicemail_ok_notifier + leave_a_voicemail_link(patient)
    elsif patient.voicemail_preference == :not_specified
      voicemail_not_specified_notifier + leave_a_voicemail_link(patient)
    end
  end

  def display_other_contact_and_phone_if_exists(patient)
    section = []
    if patient.other_contact? && patient.other_phone?
      section.push name_display_h4(patient)
      section.push other_phone_h4(patient)
      section.push patient_name_h4(patient)
    end
    safe_join section, ''
  end

  private

  def name_display_h4(patient)
    content_tag :h4,
                other_contact_name_display(patient),
                class: 'modal-title calls-request calls-other-contact'
  end

  def leave_a_voicemail_link(patient)
    link_to 'I left a voicemail for the patient',
            patient_calls_path(patient,
                               call: { status: 'Left voicemail' }),
            method: :post,
            remote: true,
            class: 'calls-response'
  end

  def no_voicemail_notifier
    "<p class='text-danger'>" \
    '<strong>Do not leave this patient a voicemail</strong>' \
    '</p>'.html_safe
  end

  def voicemail_ok_notifier
    "<p class='text-success'>Voicemail OK; " \
    'Okay to identify as DCAF</p>'.html_safe
  end

  def voicemail_not_specified_notifier
    "<p class='text-warning'><strong>Voicemail OK; " \
    'Do not identify as DCAF</strong></p>'.html_safe
  end

  def other_contact_name_display(patient)
    patient.other_contact +
      other_contact_relationship_display(patient) +
      ' is the primary contact for this patient:'
  end

  def other_phone_h4(patient)
    content_tag(:h4, patient.other_phone_display, class: 'calls-phone')
  end

  def patient_name_h4(patient)
    content_tag(:h4, "#{patient.name}'s number:", class: 'modal-title calls-request')
  end

  def other_contact_relationship_display(patient)
    if patient.other_contact_relationship?
      " (#{patient.other_contact_relationship})"
    else
      ''
    end
  end
end
