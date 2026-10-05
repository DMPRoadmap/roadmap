# frozen_string_literal: true

# Legacy Roadmap tables use signed 32-bit primary keys and matching integer
# foreign keys. PostgreSQL reports those auto-incrementing keys as :serial;
# MySQL interprets :serial as unsigned bigint, so a PostgreSQL schema dump
# cannot be loaded into MySQL. :integer creates an auto-incrementing 32-bit
# primary key on both adapters without changing the stored key values.
module DMPRoadmapSchemaDumper
  private

  def column_spec_for_primary_key(column)
    spec = super
    spec[:id] = ':integer' if spec[:id] == ':serial'
    spec
  end
end

ActiveRecord::ConnectionAdapters::SchemaDumper.prepend(DMPRoadmapSchemaDumper)
