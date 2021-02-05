# frozen_string_literal: true

class ApplicationService

  class << self

    # Returns either the name specified in dmproadmap.rb initializer or
    # the Rails application name
    def application_name
      default = Rails.application.class.name.split("::").first&.downcase
      Rails.configuration.x.application.name.downcase || default
    end

  end

end
