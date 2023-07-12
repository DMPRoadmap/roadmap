class Add < ActiveRecord::Migration[6.1]
  def change
    add_column :wips, :dmp_id, :string
  end
end
