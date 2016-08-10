class ThemesInGuidance < ActiveRecord::Migration
  def change 
 		create_table :themes_in_guidance, :id => false do |t|
      t.integer :theme_id
      t.integer :guidance_id
  	end
  end
end
