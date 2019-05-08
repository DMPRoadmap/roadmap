# frozen_string_literal

# Provides additional attributes for controllers that support OAuth functionality
module OAuthAble

  # List of trusted OAuth providers
  OAUTH_PROVIDERS = %w[zenodo]

  private

  # A valid OAuth::Client object for a given provider. Will raise an exception if the
  # provider hasn'tbe
  #
  # Returns OAuth::Client
  # Raises StandardError
  def client_for_oauth2_provider(provider)
    raise "Unknown OAuth Provider" unless provider.downcase.in?(OAUTH_PROVIDERS)
    @client_for_oauth2_provider ||= {}
    @client_for_oauth2_provider[provider] ||= begin
      OAuth2::Client.new(
        ENV["#{provider.upcase}_CLIENT_ID"],
        ENV["#{provider.upcase}_CLIENT_SECRET"],
        site: provider.classify.constantize.const_get("BASE"),
        logger: Logger.new(Rails.root.join("log", "#{provider}.log"), 'weekly')
      )
    end
  end

end