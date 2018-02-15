class ChangeOrgLinksDefault < ActiveRecord::Migration
  def up
    change_column_default :orgs, :links, '{}' 
  end
  def down
    change_column_default :orgs, :links, '[]'
  end
end
