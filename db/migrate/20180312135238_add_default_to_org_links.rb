class AddDefaultToOrgLinks < ActiveRecord::Migration
  def up
#    change_column_default(:orgs, :links, '{"org":[]}')
  end
  def down
#    change_column_default(:orgs, :links, '[]')
  end
end


