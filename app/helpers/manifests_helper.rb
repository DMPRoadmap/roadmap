# frozen_string_literal: true

# These helper methods allow devs to customise which javascript/CSS manifest file to load
# in the application layout. By setting `config.action_view.javascript_manifest_resolver`
# or `config.action_view.stylesheet_manifest_resolver` to a callable object (anything
# that responds to `#call()`) in application.rb, you can change the behaviour for your
# own deployment.
#
# Examples:
#
#  ##
#  # in application.rb
#
#  ##
#  # This will load `myapp.com.css`, if available, for requests to `myapp.com`.
#  #
#  config.action_view.stylesheet_manifest_resolver = lambda do |request|
#    "#{request.host}.css"
#  end
#
#  ##
#  # This will load `mainapp.css`, if available, for all requests
#
#  config.action_view.stylesheet_manifest_resolver = lambda do |request|
#    "mainapp.css"
#  end
#
#  ##
#  # This will load whatever MyCustomResolver returns when called:
#
#  class MyCustomResolver
#
#    def call(request)
#      # compute things...
#      return string
#    end
#
#  end
#
#  config.action_view.stylesheet_manifest_resolver = MyCustomResolver.new
#
module ManifestsHelper

  # The name of the default asset manifest files.
  DEFAULT = "application"

  # The name of the javascript manifest file to load. Defaults to application.js
  #
  # Returns String
  def javascript_manifest_file
    if Rails.application.config.x.action_view.javascript_manifest_resolver
      Rails.application.config.x.action_view.javascript_manifest_resolver.call(request)
    else
      DEFAULT
    end
  end

  # The name of the stylesheet manifest file to load. Defaults to application.css
  #
  # Returns String
  def stylesheet_manifest_file
    if Rails.application.config.x.action_view.stylesheet_manifest_resolver
      Rails.application.config.x.action_view.stylesheet_manifest_resolver.call(request)
    else
      DEFAULT
    end
  end

end
