class AddAnswerOptionsRelation < ActiveRecord::Migration
  def up
  	create_table :answers_options, :id => false do |t|
	  t.references :answer, :null => false
	  t.references :option, :null => false
	end

    add_index :answers_options, [:answer_id, :option_id]
  end

  def down
  	drop_table :answers_options
  end
end
