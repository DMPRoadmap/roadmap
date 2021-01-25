# frozen_string_literal: true

require "dragonfly"
require "dragonfly/s3_data_store"

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret Rails.application.credentials.dragonfly_secret

  url_format "/media/:job/:name"

  if Rails.env.development?
    datastore :file,
              root_path: Rails.root.join("public/system/dragonfly", Rails.env),
              server_root: Rails.root.join("public")
  else
    datastore :s3,
              url_scheme: "s3",
              # url_host: 'uc3-s3dmp-stg',
              root_path: "logos",
              bucket_name: "uc3-s3dmp-stg",
              use_iam_profile: true
  end
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
