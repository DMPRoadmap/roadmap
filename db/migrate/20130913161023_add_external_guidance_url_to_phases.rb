class AddExternalGuidanceUrlToPhases < ActiveRecord::Migration[4.2]
  def change
    add_column :phases, :external_guidance_url, :string
  end
end
