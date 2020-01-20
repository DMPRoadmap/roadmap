class AddSchemaIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :schema_id, :integer
  end
end
