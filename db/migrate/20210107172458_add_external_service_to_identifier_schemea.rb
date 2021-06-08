class AddExternalServiceToIdentifierSchemea < ActiveRecord::Migration[5.2]
  def change
    add_column :identifier_schemes, :external_service, :string
  end
end
