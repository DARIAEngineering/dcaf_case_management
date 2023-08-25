# Functions related to navigating around the pledge submission modal.
module PledgesHelper
  def submit_pledge_button
    content_tag :span, class: 'btn btn-primary btn-lg submit-btn btn-block',
                       aria: { hidden: true },
                       id: 'submit-pledge-button' do
      t('patient.menu.submit_pledge')
    end
  end

  def cancel_pledge_button
    content_tag :span, class: 'btn btn-warning btn-lg cancel-btn btn-block',
                       aria: { hidden: true },
                       id: 'cancel-pledge-button' do
      t('patient.menu.cancel_pledge')
    end
  end

  def mark_complete_button
    content_tag :span, class: 'btn btn-primary btn-lg submit-btn btn-block',
                       aria: { hidden: true },
                       id: 'submit-pledge-button' do
      t('patient.menu.mark_complete')
    end 
  end

  def mark_incomplete_button
    content_tag :span, class: 'btn btn-warning btn-lg cancel-btn btn-block',
                       aria: { hidden: true },
                       id: 'submit-pledge-button' do
      t('patient.menu.mark_incomplete')
    end 
  end

  def clinic_pledge_email(patient)
    email = patient.clinic&.email_for_pledges
    return unless email
    link_to email, 'mailto:' + email, target: '_blank'
  end

  def clinic_pledge_fax(patient)
    fax = patient.clinic&.fax
    fax
  end
end
