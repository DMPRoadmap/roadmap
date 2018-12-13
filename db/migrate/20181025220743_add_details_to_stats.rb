class AddDetailsToStats < ActiveRecord::Migration
  def change
    add_column :stats, :details, :text
  end
end
