module DMPRoadmap
  class Application < Rails::Application
    WickedPdf.config = {
      exe_path: Rails.application.secrets.wicked_pdf_path || '/usr/local/bin/wkhtmltopdf'
    }
  end
end
