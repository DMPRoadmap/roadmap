class RenameMadmpTables < ActiveRecord::Migration
  def change
    remove_foreign_key :structured_answers, :structured_data_schemas
    remove_reference :structured_answers, :structured_data_schema

    remove_foreign_key :questions, :structured_data_schemas
    remove_reference :questions, :structured_data_schema

    rename_table :structured_answers, :madmp_fragments
    rename_table :structured_data_schemas, :madmp_schemas


    add_reference :questions, :madmp_schema, index: true, foreign_key: true
    add_reference :madmp_fragments, :madmp_schema, index: true, foreign_key: true
  end
end
