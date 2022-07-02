# Functions primarily related to populating funds at the footer.
module FooterHelper
  def fax_service
    fax = Config.find_or_create_by(config_key: 'fax_service').options.try :first
    fax_uri = UriService.new(fax)
    link_to fax_uri.uri, fax_uri.uri.to_s, target: '_blank', rel: 'noopener nofollow' if fax_uri.uri
  end

  def clinic_pledge_email(patient)
    email = patient.clinic&.email_for_pledges
    link_to email, 'mailto:' + email, target: '_blank'
  end
end