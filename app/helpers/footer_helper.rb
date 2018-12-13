# Functions primarily related to populating funds at the footer.
module FooterHelper
  def fax_service
    fax = Config.find_or_create_by(config_key: 'fax_service').options.try :first
    link_to fax, fax, target: '_blank', rel: 'noopener nofollow' if fax
  end
end
