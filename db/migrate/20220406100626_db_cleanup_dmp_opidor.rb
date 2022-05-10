class DbCleanupDmpOpidor < ActiveRecord::Migration[5.2]
  def change
    # Removed old columns that are no longer in use
    remove_column(:research_outputs, :research_output_type_id) if column_exists?(:research_outputs, :research_output_type_id)
    remove_column(:research_outputs, :fullname) if column_exists?(:research_outputs, :fullname)
    remove_column(:research_outputs, :other_type_label) if column_exists?(:research_outputs, :other_type_label)
    remove_column(:research_outputs, :other_type_label) if column_exists?(:research_outputs, :other_type_label)
    remove_column(:research_outputs, :display_order) if column_exists?(:research_outputs, :display_order)
    
    rename_column(:research_outputs, :order, :display_order) if column_exists?(:research_outputs, :order)

    # Drop unused tables
    drop_table(:research_output_types) if table_exists?(:research_output_types)
  end
end
