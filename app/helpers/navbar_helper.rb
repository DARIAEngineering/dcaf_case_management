module NavbarHelper
  def cm_resources_link
    url = Config.find_or_create_by(config_key: 'resources_url').options.first

    content_tag :li do
      link_to t('navigation.cm_resources.label'), url, target: '_blank'
    end if url.present?
  end

  def spanish_or_english_link
    content_tag :li do
      if I18n.locale == I18n.default_locale 
        link_to "Español", { :locale=>'es' }
      else
        link_to "English", { :locale=>'en' }
      end
    end
  end
end
