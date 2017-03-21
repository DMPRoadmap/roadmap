class AddDmptemplateIdToGuidance < ActiveRecord::Migration
  def change
    add_column :guidances, :dmptemplate_id, :integer
  end
end
