# frozen_string_literal: true

namespace :doorkeeper do
  desc 'Ensure internal OAuth application exists'
  task ensure_internal_app: :environment do
    app = Doorkeeper::Application.find_or_create_by!(
      name: Rails.application.config.x.application.internal_oauth_app_name
    ) do |a|
      a.scopes = 'read'
      a.confidential = true
      # redirect_uri value is only used as a placeholder here (required by Doorkeeper).
      # Tokens are minted server-side for already-authenticated first-party users.
      # No redirect, authorization code, or third-party client is involved.
      a.redirect_uri = "#{Rails.application.routes.url_helpers.root_url}oauth/callback"
    end

    puts "Internal OAuth app ready (id=#{app.id}, uid=#{app.uid})"
  end
end
