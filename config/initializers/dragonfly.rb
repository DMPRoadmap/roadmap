# frozen_string_literal: true

require "dragonfly"
require "dragonfly/s3_data_store"

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret Rails.application.credentials.dragonfly[:secret]

  url_format "/media/:job/:name"

  datastore :file,
            root_path: Rails.root.join("public/system/dragonfly", Rails.env),
            server_root: Rails.root.join("public")
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
