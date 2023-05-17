class EndUserGuidance2 < ActiveRecord::Migration[6.1]
  def change
    add_column :templates, :user_guidance_output_types_title, :text
    add_column :templates, :user_guidance_output_types_description, :text
  end
end
