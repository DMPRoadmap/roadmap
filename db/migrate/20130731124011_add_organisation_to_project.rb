class AddOrganisationToProject < ActiveRecord::Migration
  def change
    add_column :projects, :organisation_id, :integer
  end
end
