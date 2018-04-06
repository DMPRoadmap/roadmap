class RenameTemplateFields < ActiveRecord::Migration
  def up
    rename_column :templates, :migrated, :archived
    rename_column :templates, :dmptemplate_id, :family_id
  end
  
  def down
    rename_column :templates, :archived, :migrated
    rename_column :templates, :family_id, :dmptemplate_id
  end
end
