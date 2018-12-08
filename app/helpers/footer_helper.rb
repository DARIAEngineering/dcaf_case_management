# Functions primarily related to populating funds at the footer.
module FooterHelper
  def fax_service
    Config.find_or_create_by(config_key: 'fax_service').options.first
  end
end
