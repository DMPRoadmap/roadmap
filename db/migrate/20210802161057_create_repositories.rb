class CreateRepositories < ActiveRecord::Migration[5.2]
  def change
    create_table :repositories do |t|
      t.string :name, null: false, index: true
      t.text :description, null: false
      t.string :homepage, index: true
      t.string :contact
      t.string :uri, null: false, index: true
      t.json :info
      t.timestamps
    end

    create_table :repositories_research_outputs do |t|
      t.belongs_to :research_output
      t.belongs_to :repository
    end
  end
end
