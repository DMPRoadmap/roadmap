class AddSlugToTheme < ActiveRecord::Migration[4.2]
  def change
    add_column :themes, :slug, :string
  end
end
