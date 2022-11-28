# frozen_string_literal: true

module DMPRoadmap
  # Configuration settings for the WKHTMLTOPDF gem
  class Application < Rails::Application
    WickedPdf.config = {
      exe_path: Rails.configuration.x.dmproadmap.wkhtmltopdf_path
    }
  end
end
