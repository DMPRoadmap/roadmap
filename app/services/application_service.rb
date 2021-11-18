# frozen_string_literal: true

class ApplicationService

  class << self

    # Gets the default language
    def default_language
      lang = Language.where(default_language: true).first
      lang.present? ? lang.abbreviation : "en"
    end

    # Returns either the name specified in config/branding.yml or
    # the Rails application name
    def application_name
      Rails.application.config.branding[:application]
        .fetch(:name, Rails.application.class.name.split('::').first).downcase
    end

  end

end
