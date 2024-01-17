# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  host = Rails.configuration.x.dmproadmap.server_host
  host = "https://#{host}" unless host.start_with?('http')
  localhost = 'http://localhost:3000'

  allow do
    if Rails.env.production?
      origins host
    elsif Rails.env.stage?
      origins localhost, host
    else
      origins localhost
    end

    resource '*', headers: :any, methods: %i[get options put post delete]
  end
end