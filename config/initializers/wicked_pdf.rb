# frozen_string_literal: true

module DMPRoadmap
  # Config for the WkhtmlToPdf C library
  class Application < Rails::Application
    WickedPdf.config = {
      exe_path: Rails.configuration.x.dmproadmap.wkhtmltopdf_path
    }
  end
end
