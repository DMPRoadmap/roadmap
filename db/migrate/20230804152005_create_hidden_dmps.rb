class CreateHiddenDmps < ActiveRecord::Migration[6.1]
  def change
    create_table :hidden_dmps do |t|
      t.references  :user, index: true, null: false
      t.string     :dmp_id, index: true, null: false
      t.timestamps

      t.index [ :dmp_id, :user_id ], unique: true
    end
  end
end
