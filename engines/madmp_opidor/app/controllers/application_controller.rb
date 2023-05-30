# frozen_string_literal: true

# Engine Application controller
class ApplicationController < ApplicationController
  protect_from_forgery with: :exception
  helper Rails.application.routes.url_helpers
end
