class AddSponsorIdToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :templates, :sponsor_id, :integer
  end
end
