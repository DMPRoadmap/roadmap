class AddUniquenessIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :departments, %i[name org_id], unique: true, name: 'unique_departments'
    add_index :orgs, :name, unique: true, name: 'unique_orgs'
    add_index :perms, :name, unique: true, name: 'unique_perms'
    add_index :question_formats, :title, unique: true, name: 'unique_question_formats'
    add_index :regions, :abbreviation, unique: true, name: 'unique_regions'
  end
end
