# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules/@fortawesome/fontawesome-free/webfonts')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# Bootstrap and TinyMCE expect their files to live in a specific place, so copy them over
puts "Copying Bootstrap glyphicons to the public directory ..."
source_dir = Dir.glob(Rails.root.join('node_modules', 'bootstrap', 'fonts', 'glyphicons-halflings-regular.*'))
destination_dir = Rails.root.join('public', 'fonts', 'bootstrap')
FileUtils.mkdir_p(destination_dir)
FileUtils.cp_r(source_dir, destination_dir)

puts "Copying TinyMCE skins to the public directory ..."
source_dir = Dir.glob(Rails.root.join('node_modules', 'tinymce', 'skins', 'ui', 'oxide'))
destination_dir = Rails.root.join('public', 'tinymce', 'skins')
FileUtils.mkdir_p(destination_dir)
FileUtils.cp_r(source_dir, destination_dir)

puts "Copying React translations to the public directory ..."
source_dir = Dir.glob(Rails.root.join('app', 'javascript', 'dmp_opidor_react', 'public', 'locales'))
destination_dir = Rails.root.join('public')
FileUtils.mkdir_p(destination_dir)
FileUtils.cp_r(source_dir, destination_dir)
