class UpdateTypeColumnInQuestions < ActiveRecord::Migration[4.2]
  	def change
    	change_table :questions do |t|
      		t.rename :type, :question_type
    	end
	end
end
