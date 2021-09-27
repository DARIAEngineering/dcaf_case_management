# Functions to display call-related items.
module CallsHelper
  def display_voicemail_link_with_warning(patient)
    if patient.voicemail_preference == 'no'
      no_voicemail_notifier
    elsif patient.voicemail_preference == 'yes'
      voicemail_ok_notifier + leave_a_voicemail_link(patient)
    elsif patient.voicemail_preference == 'not_specified'
      voicemail_not_specified_notifier + leave_a_voicemail_link(patient)
    else
      # custom value for voicemail 
      voicemail_custom_notifier(patient) + leave_a_voicemail_link(patient)
    end
  end

  def display_other_contact_and_phone_if_exists(patient)
    section = []
    if patient.other_contact? || patient.other_phone?
      section.push name_display_h4(patient)
      section.push other_phone_h4(patient) if patient.other_phone?
      section.push patient_name_h4(patient)
    end
    safe_join section, ''
  end

  def display_reached_patient_link(patient)
    content_tag :p do
      link_to t('call.new.result.reached_patient'),
              patient_calls_path(patient,
                                 call: { status: :reached_patient }),
              method: :post,
              class: 'btn btn-primary calls-btn'
    end
  end

  def display_couldnt_reach_patient_link(patient)
    content_tag :p do
      link_to t('call.new.result.did_not_reach_patient'),
              patient_calls_path(patient,
                                 call: { status: :couldnt_reach_patient }),
              method: :post, remote: true,
              class: 'calls-response'
    end
  end

  private

  def name_display_h4(patient)
    content_tag :h4,
                other_contact_name_display(patient),
                class: 'modal-title calls-request calls-other-contact'
  end

  def leave_a_voicemail_link(patient)
    link_to t('call.new.result.left_voicemail'),
            patient_calls_path(patient,
                               call: { status: :left_voicemail }),
            method: :post,
            remote: true,
            class: 'calls-response'
  end

  def no_voicemail_notifier
    content_tag :p, class: 'text-danger' do
      content_tag :strong, t('call.new.voicemail_instructions.no_voicemail')
    end
  end

  def voicemail_ok_notifier
    content_tag :p, class: 'text-success' do
      content_tag :strong, t('call.new.voicemail_instructions.voicemail_identify', fund: ActsAsTenant.current_tenant.name)
    end
  end

  def voicemail_not_specified_notifier
    content_tag :p, class: 'text-warning' do
      content_tag :strong, t('call.new.voicemail_instructions.voicemail_no_identify', fund: ActsAsTenant.current_tenant.name)
    end
  end

  def voicemail_custom_notifier(patient)
      content_tag :p, class: 'text-warning' do
          content_tag :strong, patient.voicemail_preference
      end
  end

  def other_contact_name_display(patient)
    if patient.other_contact?
      t('call.other_contact.other_contact', name: "#{patient.other_contact}",
                                            rel: "#{other_contact_relationship_display(patient)}",
                                            punc: "#{patient.other_phone? ? ':' : '.'}")
    else
      t('call.other_contact.primary')
    end
  end

  def other_phone_h4(patient)
    content_tag :h4, patient.other_phone_display, class: 'calls-phone'
  end

  def patient_name_h4(patient)
    content_tag :h4,
                t('call.other_contact.number', name: "#{patient.name}"),
                class: 'modal-title calls-request'
  end

  def other_contact_relationship_display(patient)
    if patient.other_contact_relationship?
      " (#{patient.other_contact_relationship})"
    else
      ''
    end
  end
end
