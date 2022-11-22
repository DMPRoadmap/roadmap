# frozen_string_literal: true

module DMPRoadmap
  # Configuration settings for the WKHTMLTOPDF gem
  class Application < Rails::Application
    WickedPdf.config = {
      exe_path: ENV.fetch('WICKED_PDF_PATH', '/usr/local/bin/wkhtmltopdf')
    }
  end
end
