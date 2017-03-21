class AddFieldToGuidances < ActiveRecord::Migration
  def change
     add_column :guidances, :published, :boolean
     Guidance.find_each do |guidance|
        guidance.published = true
        guidance.save!
     end
  end
end
