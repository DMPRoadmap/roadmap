class CreateUserTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :user_types do |t|
      t.string :user_type_name
      t.text :user_type_desc

      t.timestamps
    end
  end
end
