# frozen_string_literal: true

module DMPRoadmap

  class Application < Rails::Application

    # WickedPdf.config = {
    #   exe_path: Rails.root.join("bin", "wkhtmltopdf")
    # }
    if Rails.env.development? || Rails.env.test?
      WickedPdf.config = { exe_path: "/Users/briley/.rbenv/shims/wkhtmltopdf" } #`which wkhtmltopdf` } #"/Users/briley/.rbenv/shims/wkhtmltopdf" }
    else
      WickedPdf.config = {
        exe_path: "/dmp/local/bin/wkhtmltopdf"
      }
    end
  end

end
