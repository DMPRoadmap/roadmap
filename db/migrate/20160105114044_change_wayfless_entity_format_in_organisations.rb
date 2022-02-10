class ChangeWayflessEntityFormatInOrganisations < ActiveRecord::Migration[4.2]

  def change
    change_column :organisations, :wayfless_entity, :string
  end

end
