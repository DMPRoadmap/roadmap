class EndUserGuidance < ActiveRecord::Migration[6.1]
  def change
    add_column :templates, :user_guidance_research_outputs, :text
    add_column :templates, :user_guidance_repositories, :text
    add_column :templates, :user_guidance_metadata_standards, :text
    add_column :templates, :user_guidance_licenses, :text
  end
end
