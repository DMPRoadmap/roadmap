class ChangeVersionsPublished < ActiveRecord::Migration[4.2]
  def change
    add_column :versions, :published_tmp, :boolean

    # Since we ultimately drop the Version model we must check for it before
    # attempting to manipulate data
    if table_exists?('versions')
      Version.reset_column_information # make the new column available to model methods
      Version.all.each do |v|
        v.published_tmp = v.published == 't' ? true : false
        v.save
      end
    end
    
    remove_column :versions, :published
    rename_column :versions, :published_tmp, :published
  end
end
