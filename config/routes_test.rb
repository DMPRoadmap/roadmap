# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your test-specific routes here

  # This route will return an empty response with a 200 OK status code
  # when the browser requests the favicon.ico file.
  get '/favicon.ico', to: proc { |_env| [200, {}, ['']] }
end
