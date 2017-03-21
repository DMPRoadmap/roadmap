class RemoveFieldFromPhases < ActiveRecord::Migration
  def change
    remove_column :phases, :external_guidance_url
  end

end
