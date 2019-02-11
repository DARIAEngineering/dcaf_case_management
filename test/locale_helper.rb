module ActionDispatch::Integration
    class Session
      def default_url_options
        { locale: I18n.locale }
      end
    end 
end
