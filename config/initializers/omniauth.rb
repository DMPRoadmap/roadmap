Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shibboleth, {
    # We're using a UK Access Management Federation IdPs here
    # Shibboleth server config needs to return eppn and persistent-id attributes
    # Priority given to eppn in controller if present, assuming persistent-id always populated
    # Doing this the omniauth way rather than using REMOTE_USER
    # See controllers/users/omniauth_callbacks_controller.rb
    # Shibboleth authentication is enabled in config/application.rb
    :uid_field => :"persistent-id",
    :fields => [],
    :extra_fields => [
      :eppn,
      :affiliation,
      :entitlement,
      :"unscoped-affiliation",
      :"targeted-id",
      :mail
    ],
  }
end
