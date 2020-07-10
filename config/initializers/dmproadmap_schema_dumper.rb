# frozen_string_literal: true

module ActiveRecord

  # The Rails 5.x SchemaDumper includes an `options:` arrgument on table definitions
  # that is not DB agnostic. This Monkey Patch comments out the `options:` section.
  #
  # TODO: Determine if this is still necessary in Rails 6.x+
  class SchemaDumper

    # Method definition taken from the 5.2-stable branch of ActiveRecord:
    #  https://github.com/rails/rails/blob/5-2-stable/activerecord/lib/active_record/schema_dumper.rb
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def table(table, stream)
      columns = @connection.columns(table)
      begin
        tbl = StringIO.new

        # first dump primary key column
        pk = @connection.primary_key(table)

        tbl.print "  create_table #{remove_prefix_and_suffix(table).inspect}"

        case pk
        when String
          tbl.print ", primary_key: #{pk.inspect}" unless pk == "id"
          pkcol = columns.detect { |c| c.name == pk }
          pkcolspec = column_spec_for_primary_key(pkcol)
          tbl.print ", #{format_colspec(pkcolspec)}" if pkcolspec.present?
        when Array
          tbl.print ", primary_key: #{pk.inspect}"
        else
          tbl.print ", id: false"
        end

        # Commenting out Table Options because they are not DB agnostic
        # table_options = @connection.table_options(table)
        # if table_options.present?
        #   tbl.print ", #{format_options(table_options)}"
        # end

        tbl.puts ", force: :cascade do |t|"

        # then dump all non-primary key columns
        columns.each do |column|
          unless @connection.valid_type?(column.type)
            raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'"
          end
          next if column.name == pk

          type, colspec = column_spec(column)
          tbl.print "    t.#{type} #{column.name.inspect}"
          tbl.print ", #{format_colspec(colspec)}" if colspec.present?
          tbl.puts
        end

        indexes_in_create(table, tbl)

        tbl.puts "  end"
        tbl.puts

        tbl.rewind
        stream.print tbl.read
      rescue StandardError => e
        stream.puts "# Could not dump table #{table.inspect} because of following #{e.class}"
        stream.puts "#   #{e.message}"
        stream.puts
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  end

end
