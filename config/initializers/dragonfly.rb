# frozen_string_literal: true

require "dragonfly"

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "9188325fe2fc25afb4eff83fe9c172f8a324d056c359db4fac11d93ecd3e3865"

  url_format "/media/:job/:name"

  # If the DRAGONFLY_AWS environment variable is set to 'true', configure the app to
  # use Amazon S3 for storage:
  if ENV["DRAGONFLY_AWS"] == "true"
    require "dragonfly/s3_data_store"
    datastore(:s3, {
                bucket_name: ENV["AWS_BUCKET_NAME"],
                access_key_id: ENV["AWS_ACCESS_KEY_ID"],
                secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
                region: ENV["AWS_REGION"],
                root_path: Rails.env,
                url_scheme: "https"
              })

  # Otherwise, revert to the default:
  else

    datastore(:file, {
                root_path: Rails.root.join("public/system/dragonfly", Rails.env),
                server_root: Rails.root.join("public")
              })

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
