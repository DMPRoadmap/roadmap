class RenameObjectColumnInStructuredSchemas < ActiveRecord::Migration
  def change
    rename_column :structured_data_schemas, :object, :classname
  end
end
