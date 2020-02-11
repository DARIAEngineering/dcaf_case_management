# Functions primarily related to populating funds at the footer.
module FooterHelper
  def fax_service
    fax = Config.find_or_create_by(config_key: 'fax_service').options.try :first
    fax_uri = UriService.new(fax)
    link_to fax_uri.uri, fax_uri.secure_scheme_uri!.to_s, target: '_blank', rel: 'noopener nofollow' if fax_uri.uri
  end
end
