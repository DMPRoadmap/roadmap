class AddDefaultToJsonColumns < ActiveRecord::Migration[5.2]
  def change
    change_column :madmp_schemas, :schema, :json, default: {}
    change_column :madmp_fragments, :data, :json, default: {}
  end
end
