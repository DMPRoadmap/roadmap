class RenameObjectColumnInStructuredSchemas < ActiveRecord::Migration[4.2]
  def change
    rename_column :structured_data_schemas, :object, :classname
  end
end
