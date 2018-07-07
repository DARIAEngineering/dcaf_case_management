module NavbarHelper
  def cm_resources_link
    url = Config.find_or_create_by(config_key: 'resources_url').options.first

    content_tag :li do
      link_to 'CM Resources', url, target: '_blank'
    end if url.present?
  end
end
