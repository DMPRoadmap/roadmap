# frozen_string_literal: true

module DMPRoadmap
  # wkhtmlpdf configurations
  class Application < Rails::Application
    WickedPdf.config = {
      exe_path: Rails.application.secrets.wicked_pdf_path || '/usr/bin/wkhtmltopdf',
      proxy: Rails.application.secrets.wicked_pdf_proxy || ''
    }
  end
end
