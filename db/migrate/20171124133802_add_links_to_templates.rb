class AddLinksToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :links, :string, default: '{"funder":[], "sample_plan":[]}'
  end
end
