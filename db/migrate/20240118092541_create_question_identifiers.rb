class CreateQuestionIdentifiers < ActiveRecord::Migration[6.1]
  def change
    create_table :question_identifiers do |t|
      t.integer :question_id
      t.string :value
      t.string :name

      t.timestamps
    end
  end
end
