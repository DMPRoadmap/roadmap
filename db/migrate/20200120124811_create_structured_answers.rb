class CreateStructuredAnswers < ActiveRecord::Migration
  def change
    create_table :structured_answers do |t|
      t.json :data
      t.integer :answer_id
      t.integer :structured_data_schema_id

      t.timestamps null: false
    end
  end
end
