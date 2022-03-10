# frozen_string_literal: true

# Controller that handles a language change
class SessionLocalesController < ApplicationController
  # rubocop:disable Metrics/AbcSize
  def update
    session[:locale] = params[:locale] if available_locales.include?(params[:locale].intern)

    # If this is part of the sign in/up workflow then just go to the root path
    if user_session_path == URI.parse(request.referer).path
      redirect_to root_path
    else
      redirect_back(fallback_location: root_path)
    end
  rescue StandardError
    redirect_back(fallback_location: root_path)
  end
  # rubocop:enable Metrics/AbcSize

  private

  def available_locales
    I18n.available_locales
  end
end
