# frozen_string_literal: true

module DMPRoadmap

  class Application < Rails::Application

    WickedPdf.config = {
      exe_path: "/dmp/local/bin/wkhtmltopdf"
    }

  end

end
