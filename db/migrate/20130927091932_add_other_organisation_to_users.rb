class AddOtherOrganisationToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :other_organisation, :string
  end
end
