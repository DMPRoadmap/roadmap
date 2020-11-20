class CreateComments < ActiveRecord::Migration[4.2]
    def change
        create_table :comments do |t|
            t.integer :user_id
            t.integer :question_id
            t.text :text

            t.timestamps
        end
        

   end
end
