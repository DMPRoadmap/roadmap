class AddFieldToGuidances < ActiveRecord::Migration[4.2]
  def change
     add_column :guidances, :published, :boolean

     if table_exists?('guidances')
       Guidance.find_each do |guidance|
          guidance.published = true
          guidance.save!
       end
     end
  end
end
