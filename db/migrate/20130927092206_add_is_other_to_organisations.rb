class AddIsOtherToOrganisations < ActiveRecord::Migration[4.2]
  def change
    add_column :organisations, :is_other, :boolean
  end
end
