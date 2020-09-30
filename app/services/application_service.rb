# frozen_string_literal: true

class ApplicationService

  class << self

    # Returns either the name specified in dmproadmap.rb initializer or
    # the Rails application name
    def application_name
      default = Rails.application.class.name.split("::").first
      Rails.configuration.x.application.fetch(:name, default).downcase
    end

  end

end
