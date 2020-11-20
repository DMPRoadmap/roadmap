class AddDefaultToOrgLinks < ActiveRecord::Migration[4.2]
  def up
#    change_column_default(:orgs, :links, '{"org":[]}')
  end
  def down
#    change_column_default(:orgs, :links, '[]')
  end
end


