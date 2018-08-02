class RemoveDefaultsFromLinks < ActiveRecord::Migration
  def up
    change_column :templates, :links, :text, default: nil
    change_column :orgs, :links, :text, default: nil
  end
  def down
    change_column :templates, :links, :text,
                  default: "{\"funder\":[], \"sample_plan\":[]}"
    change_column :orgs, :links, :text,
                  default: "{\"funder\":[], \"sample_plan\":[]}"
  end
end
