class AddNewColumnToOrgs < ActiveRecord::Migration[6.1]
  def change
    add_column :orgs, :add_question_identifiers, :boolean, default: false, null: false
    Org.update_all(add_question_identifiers: false)
  end
end
