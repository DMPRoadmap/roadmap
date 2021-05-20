# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: Rails.configuration.x.dmproadmap.cookie_key,
                                                      same_site: :lax
