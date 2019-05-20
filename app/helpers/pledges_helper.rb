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
end
