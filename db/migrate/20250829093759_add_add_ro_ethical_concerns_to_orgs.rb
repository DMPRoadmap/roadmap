class AddAddRoEthicalConcernsToOrgs < ActiveRecord::Migration[6.1]
  def change
    add_column :orgs, :add_ro_ethical_concerns, :boolean, default: true, null: false
    Org.update_all(add_ro_ethical_concerns: true)
  end
end