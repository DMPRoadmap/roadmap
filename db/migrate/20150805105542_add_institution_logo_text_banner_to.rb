class AddInstitutionLogoTextBannerTo < ActiveRecord::Migration
  def change
    add_column :organisations, :banner_text, :text
    add_column :organisations, :logo_file_name, :string
    remove_column :organisations, :logo_file_id
    remove_column :organisations, :banner_file_id
  end
end
