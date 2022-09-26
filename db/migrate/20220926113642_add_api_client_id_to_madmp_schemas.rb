class AddApiClientIdToMadmpSchemas < ActiveRecord::Migration[5.2]
  def change
    add_reference :madmp_schemas, :api_client, foreign_key: true
  end
end
