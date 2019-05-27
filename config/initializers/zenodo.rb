# frozen_string_literal

module Zenodo

  ENV["ZENODO_CLIENT_ID"] || warn("No ZENODO_CLIENT_ID ENV variable found.")

  ENV["ZENODO_CLIENT_SECRET"] || warn("No ZENODO_CLIENT_SECRET ENV variable found.")

  # Base URL for the Zenodo API. Will default to sandbox unless in production mode
  BASE = begin
    Rails.env.production? ? 'https://zenodo.org' : 'https://sandbox.zenodo.org'
  end

end
