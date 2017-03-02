module PledgesHelper
  def submit_pledge_button
    content_tag :span, class: 'btn btn-primary btn-lg submit-btn btn-block',
                       aria: { hidden: true },
                       id: 'submit-pledge-button' do
      'Submit pledge'
    end
  end
end
