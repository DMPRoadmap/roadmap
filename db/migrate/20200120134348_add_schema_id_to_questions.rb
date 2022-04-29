class AddSchemaIdToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_reference :questions, :structured_data_schema, foreign_key: true, index: true
  end
end
