Rails.application.config.assets.paths << Rails.root.join('node_modules')

Rails.application.config.assets.precompile += %w[ tinymce/lightgray/skin.min.css ]


if Rails.env.staging? or Rails.env.production?

  # Compress JavaScripts and CSS.

  Rails.application.config.assets.css_compressor = :sass

  Rails.application.config.sass.inline_source_maps = false

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  Rails.application.config.assets.compile = false

  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  Rails.application.config.assets.debug = false

  # yet still be able to expire them through the digest params.
  Rails.application.config.assets.digest = true

else

  Rails.application.config.sass.inline_source_maps = true

  Rails.application.config.assets.compile = true

  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  Rails.application.config.assets.debug = true

  Rails.application.config.assets.digest = false

end
