class QuestionFormats < ActiveRecord::Migration[4.2]
  def change 
 		create_table :question_formats do |t|
      t.string :title
      t.text :description
      
      t.timestamps
  	end
  end
end
