class AddIsOtherToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :is_other, :boolean
  end
end
