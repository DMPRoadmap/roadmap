class AddOrganisationToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :organisation_id, :integer
  end
end
