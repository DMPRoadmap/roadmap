class AddSchemaIdToQuestions < ActiveRecord::Migration
  def change
    add_reference :questions, :schema_id, foreign_key: true, index: true
  end
end
