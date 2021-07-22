class RemoveWayflessEntityFromOrgs < ActiveRecord::Migration[4.2]
  def up
    if column_exists?(:orgs, :wayfless_entity)
      remove_column :orgs, :wayfless_entity
    end
  end

  def down
    add_column :orgs, :wayfless_entity, :string
  end
end
