class AddSortNameToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :sort_name, :string
  end
end
