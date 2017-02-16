class RemoveUnusedFieldsFromOrganisations < ActiveRecord::Migration
  def change
    remove_column :organisations, :stylesheet_file_id, :integer
    remove_column :organisations, :domain, :string
  end
end
