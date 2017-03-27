module PledgesHelper
  def submit_pledge_button
    content_tag :span, class: 'btn btn-primary btn-lg submit-btn btn-block',
                       aria: { hidden: true },
                       id: 'submit-pledge-button' do
      'Submit pledge'
    end
  end

  def cancel_pledge_button
    content_tag :span, class: 'btn btn-warning btn-lg cancel-btn btn-block',
                       aria: { hidden: true },
                       id: 'cancel-pledge-button' do
      'Cancel pledge'
    end
  end
end
