class CreateFieldOfSciencesRepositories < ActiveRecord::Migration[5.2]
  def change
    create_table :fos_repositories do |t|
      t.references :fos, null: false
      t.references :repository, null: false
      t.timestamps
    end
  end
end
