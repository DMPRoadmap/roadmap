class V4Cleanup < ActiveRecord::Migration[6.1]
  def change
    remove_column :repositories, :custom_repository_owner_template_id
    remove_column :research_outputs, :output_type
    remove_column :research_outputs, :output_type_description
  end
end
