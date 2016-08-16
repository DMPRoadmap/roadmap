class CreateSuggestedAnswers < ActiveRecord::Migration
  def change
    create_table :suggested_answers do |t|
      t.references :question
      t.references :organisation
      t.text :text
      t.timestamps
    end
  end
end
