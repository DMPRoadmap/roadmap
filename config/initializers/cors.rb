# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    if Rails.env.production?
      origins ENV['DMPROADMAP_HOST']
    else
      origins 'http://localhost:3000', ENV['DMPROADMAP_HOST']
    end

    resource '*', headers: :any, methods: %i[get put post delete]
  end
end