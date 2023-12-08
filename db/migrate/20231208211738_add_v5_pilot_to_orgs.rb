class AddV5PilotToOrgs < ActiveRecord::Migration[6.1]
  def change
    add_column :orgs, :v5_pilot, :boolean, default: false, index: true
  end
end
