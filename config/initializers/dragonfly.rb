# frozen_string_literal: true

require 'dragonfly'

require 'dragonfly/s3_data_store' unless Rails.env.test?

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret Rails.configuration.x.dmproadmap.dragonfly_secret

  url_format '/media/:job/:name'

  if Rails.env.development? || Rails.env.test?
    datastore :file,
              root_path: Rails.public_path.join('system/dragonfly', Rails.env),
              server_root: Rails.public_path
  else
    datastore :s3,
              url_scheme: Rails.configuration.x.dmproadmap.dragonfly_url_scheme,
              url_host: Rails.configuration.x.dmproadmap.dragonfly_bucket,
              root_path: Rails.configuration.x.dmproadmap.dragonfly_root_path,
              bucket_name: Rails.configuration.x.dmproadmap.dragonfly_bucket,
              use_iam_profile: true,
              storage_headers: { 'x-amz-acl': 'bucket-owner-full-control' }
  end
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveSupport.on_load(:active_record) { extend Dragonfly::Model }
  ActiveSupport.on_load(:active_record) { extend Dragonfly::Model::Validations }
end
