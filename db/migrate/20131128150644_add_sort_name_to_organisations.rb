class AddSortNameToOrganisations < ActiveRecord::Migration[4.2]
  def change
    add_column :organisations, :sort_name, :string
  end
end
