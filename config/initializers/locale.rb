# frozen_string_literal: true

# This initilializer should not be removed unless all internationalisation is handled by
# gettext_rails
<<<<<<< HEAD
require_relative('../application.rb')

DMPRoadmap::Application.config.i18n.load_path += Dir[
  Rails.root.join("config", "locales", "**", "*.yml").to_s
=======
DMPRoadmap::Application.config.i18n.load_path += Dir[
  Rails.root.join('config', 'locales', '**', '*.yml').to_s
>>>>>>> upstream/master
]
