class RemoveUnusedFieldsFromOrganisations < ActiveRecord::Migration[4.2]
  def change
    remove_column :organisations, :stylesheet_file_id, :integer
    remove_column :organisations, :domain, :string
  end
end
