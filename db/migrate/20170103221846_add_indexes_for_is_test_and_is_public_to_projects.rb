class AddIndexesForIsTestAndIsPublicToProjects < ActiveRecord::Migration
  def change
    add_index :projects, [:id, :is_test, :is_public]
  end
end
