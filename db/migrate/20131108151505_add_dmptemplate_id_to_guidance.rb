class AddDmptemplateIdToGuidance < ActiveRecord::Migration[4.2]
  def change
    add_column :guidances, :dmptemplate_id, :integer
  end
end
