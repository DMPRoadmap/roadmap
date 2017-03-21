class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :question_text
      t.string :question_type
      t.text :question_default_value
      t.text :question_suggested_answer
      t.text :question_guidance
      t.integer :question_order
      t.integer :question_parent_id
      t.integer :question_dependency_id
      t.text :question_dependency_text
      t.integer :section_id

      t.timestamps
    end
  end
end
