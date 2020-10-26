module DMPRoadmap
  class Application < Rails::Application
    WickedPdf.config = {
      exe_path: Rails.application.secrets.wicked_pdf_path || '/usr/bin/wkhtmltopdf',
      proxy: Rails.application.secrets.wicked_pdf_proxy || ''
    }
  end
end
