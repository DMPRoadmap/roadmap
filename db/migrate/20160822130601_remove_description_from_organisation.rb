class RemoveDescriptionFromOrganisation < ActiveRecord::Migration
  def change
    remove_column :organisations, :description
  end
end
