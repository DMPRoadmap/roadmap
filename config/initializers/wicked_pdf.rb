# frozen_string_literal: true

module DMPRoadmap
  # WickedPDF gem configuration
  class Application < Rails::Application
    WickedPdf.configure do |c|
      c.exe_path = ENV.fetch('WICKED_PDF_PATH', '/usr/local/bin/wkhtmltopdf')
    end
  end
end
