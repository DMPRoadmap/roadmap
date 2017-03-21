class AddFieldsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :identifier, :string
    add_column :projects, :description, :string
    add_column :projects, :principal_investigator, :string
    add_column :projects, :principal_investigator_identifier, :string
    add_column :projects, :data_contact, :string
  end
end
