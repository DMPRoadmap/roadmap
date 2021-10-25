class CreateOptionWarnings < ActiveRecord::Migration[4.2]
  def change
    create_table :option_warnings do |t|
      t.references :organisation
      t.references :option
      t.text :text
      t.timestamps
    end
  end
end
