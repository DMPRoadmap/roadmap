# frozen_string_literal: true

module DMPRoadmap

  class Application < Rails::Application

    if Rails.env.development?
      WickedPdf.config = { exe_path: "/Users/briley/.rbenv/shims/wkhtmltopdf" }
    else
      WickedPdf.config = {
        exe_path: "/dmp/local/bin/wkhtmltopdf"
      }
    end
  end

end
