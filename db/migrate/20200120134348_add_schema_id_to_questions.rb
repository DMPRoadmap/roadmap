class AddSchemaIdToQuestions < ActiveRecord::Migration
  def change
    add_reference :questions, :structured_data_schema, foreign_key: true, index: true
  end
end
