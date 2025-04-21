# frozen_string_literal: true

# This initializer should not be removed unless all internationalisation is handled by
# gettext_rails
DMPRoadmap::Application.config.i18n.load_path += Dir[
  Rails.root.join('config', 'locales', '**', '*.yml').to_s
]
