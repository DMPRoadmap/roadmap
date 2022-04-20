# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

<<<<<<< HEAD
Rails.application.config.assets.precompile += %w[
  tinymce/lightgray/skin.min,
  tinymce/lightgray/content.min
 ]

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"
=======
# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
>>>>>>> upstream/master

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
<<<<<<< HEAD
Rails.application.config.assets.paths << Rails.root.join("node_modules")
=======
Rails.application.config.assets.paths << Rails.root.join('node_modules')
>>>>>>> upstream/master

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
