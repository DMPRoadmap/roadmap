class AddOtherOrganisationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :other_organisation, :string
  end
end
