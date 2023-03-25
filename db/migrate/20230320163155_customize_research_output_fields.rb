class CustomizeResearchOutputFields < ActiveRecord::Migration[6.1]
  def change
    add_column :templates, :customize_output_types, :boolean, default: false
    add_column :templates, :customize_repositories, :boolean, default: false
    add_column :templates, :customize_metadata_standards, :boolean, default: false
    add_column :templates, :customize_licenses, :boolean, default: false
  end
end
