# Functions primarily related to populating funds at the footer.
module FooterHelper
  def fax_service
    service = Config.find_or_create_by(config_key: 'fax_service').fax_service
  end

  def fax_number
    number = Config.find_or_create_by(config_key: 'fax_service').fax_number
  end
end
