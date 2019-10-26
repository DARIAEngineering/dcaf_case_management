# Functions primarily related to populating funds at the footer.
module FooterHelper
  def fax_service
    fax = Config.find_or_create_by(config_key: 'fax_service').options.try :first
    if fax
      begin
        fax_link = URI.parse(fax) 
        fax_link.scheme = "https"
        link_to fax, fax_link.to_s, target: '_blank', rel: 'noopener nofollow'
      rescue URI::Error
        nil
      end
    end
  end
end
