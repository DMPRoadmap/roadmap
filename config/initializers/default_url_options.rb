Rails.application.routes.default_url_options[:host] = ENV["DMPROADMAP_HOSTS"].split(",").first

Rails.application.config.action_mailer.default_url_options = { host: ENV["HOST_URL"] }