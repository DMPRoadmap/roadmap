class RemoveDescriptionFromOrganisation < ActiveRecord::Migration[4.2]
  def change
    remove_column :organisations, :description
  end
end
