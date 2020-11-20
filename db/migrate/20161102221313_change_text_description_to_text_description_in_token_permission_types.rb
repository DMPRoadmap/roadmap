class ChangeTextDescriptionToTextDescriptionInTokenPermissionTypes < ActiveRecord::Migration[4.2]
  def change
    if column_exists?(:token_permission_types, :text_desription)
      rename_column :token_permission_types, :text_desription, :text_description
    end
  end
end
