class CreateStructuredAnswers < ActiveRecord::Migration
  def change
    create_table :structured_answers do |t|
      t.json :data
      t.belongs_to :answer, foreign_key: true, index: true
      t.belongs_to :structured_data_schema, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
