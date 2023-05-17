class DefineTemplateCustomRepositories < ActiveRecord::Migration[6.1]
  def change
    add_column :repositories, :custom_repository_owner_template_id, :integer, null: true, ingex: true
  end
end
