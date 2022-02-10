class RemoveFieldFromPhases < ActiveRecord::Migration[4.2]
  def change
    remove_column :phases, :external_guidance_url
  end

end
