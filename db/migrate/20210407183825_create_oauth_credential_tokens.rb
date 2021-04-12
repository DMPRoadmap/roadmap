class CreateOauthCredentialTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :oauth_credential_tokens do |t|
      t.integer  :resource_owner_id, null: false, index: true
      t.integer  :application_id,    null: false, index: true
      t.string   :token,             null: false, index: true, unique: true
      t.datetime :created_at,        null: false
      t.datetime :revoked_at
      t.datetime :last_access_at
      t.string   :scopes,            null: false, default: 'public'
    end

    add_index :oauth_credential_tokens, %i[resource_owner_id application_id revoked_at],
                                        name: 'oauth_credential_tokens_by_user_and_api_client'

    add_foreign_key :oauth_credential_tokens, :oauth_applications, column: :application_id
    add_foreign_key :oauth_credential_tokens, :users, column: :resource_owner_id
  end

  # Add a UID column to the Users table for use with the OauthCredentialToken above
  add_column :users, :uid, :string, index: true

  # Add a trusted flag to the ApiClient that will be usedd to determine if they are required to get
  # a User's OAuth authorization to interact with data
  add_column :oauth_applications, :trusted, :boolean, default: false
end
