class AddDetailsToStats < ActiveRecord::Migration[4.2]
  def change
    add_column :stats, :details, :text
  end
end
