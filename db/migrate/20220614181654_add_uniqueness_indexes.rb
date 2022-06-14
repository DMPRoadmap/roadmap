class AddUniquenessIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :departments, %i[name org_id], unique: true
    add_index :orgs, :name, unique: true
    add_index :perms, :name, unique: true
    add_index :question_formats, :title, unique: true
    add_index :regions, :abbreviation, unique: true
  end
end
