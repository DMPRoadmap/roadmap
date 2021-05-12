class CreateExternalApiAccessTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :external_api_access_tokens do |t|
      t.references :user, null: false, index: true
      t.string :external_service_name, null: false, index: true
      t.string :access_token, null: false
      t.string :refresh_token
      t.datetime :expires_at, index: true
      t.datetime :revoked_at
      t.timestamps
      t.index [:user_id, :external_service_name], name: "index_external_tokens_on_user_and_service"
    end
  end
end
