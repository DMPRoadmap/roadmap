class RemoveTooltipsTemplatePreferences < ActiveRecord::Migration[6.1]
  def change
    remove_column :templates, :user_guidance_output_types_title
    remove_column :templates, :user_guidance_output_types_description
  end
end
