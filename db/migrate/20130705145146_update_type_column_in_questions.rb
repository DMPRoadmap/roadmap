class UpdateTypeColumnInQuestions < ActiveRecord::Migration
  	def change
    	change_table :questions do |t|
      		t.rename :type, :question_type
    	end
	end
end
