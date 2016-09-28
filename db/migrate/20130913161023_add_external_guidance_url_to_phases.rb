class AddExternalGuidanceUrlToPhases < ActiveRecord::Migration
  def change
    add_column :phases, :external_guidance_url, :string
  end
end
