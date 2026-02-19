class AllowNullRedirectUriInOauthApplications < ActiveRecord::Migration[7.1]
  def change
    # We currently have `allow_blank_redirect_uri true` in
    # `config/initializers/doorkeeper.rb`. Removing the NOT NULL constraint
    # allows us to save OAuthApplications with blank redirect_uri values
    # https://github.com/doorkeeper-gem/doorkeeper/wiki/Allow-blank-redirect-URI-for-Applications
    change_column_null :oauth_applications, :redirect_uri, true
  end
end
