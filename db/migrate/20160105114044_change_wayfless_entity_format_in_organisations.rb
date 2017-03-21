class ChangeWayflessEntityFormatInOrganisations < ActiveRecord::Migration

  def change
    change_column :organisations, :wayfless_entity, :string
  end

end
