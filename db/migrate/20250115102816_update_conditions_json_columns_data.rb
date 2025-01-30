# This migration runs SQL for MySQL databases or POSTGRESQL database (default).
class UpdateConditionsJsonColumnsData < ActiveRecord::Migration[7.1]
  # rubocop:disable Metrics/MethodLength
  def change
    if ActiveRecord::Base.connection.adapter_name.downcase.include?('mysql')
      # MySQL sql
      execute <<-SQL
        UPDATE conditions
        SET
          option_list = CONCAT(
            '[',
            REPLACE(
              REPLACE(
                REPLACE(option_list, '---\r\n-', ''),
                '\r\n-',
                ','
              ),
              '\r\n',
              ''
            ),
            ']'
          ),
          remove_data = CONCAT(
            '[',
            REPLACE(
              REPLACE(
                REPLACE(remove_data, '---\r\n-', ''),
                '\r\n-',
                ','
              ),
              '\r\n',
              ''
            ),
            ']'
          )
        WHERE option_list LIKE '---%';
      SQL
    else
      # POSTGRES SQL
      execute <<-SQL
        UPDATE conditions
SET
    option_list = concat (
           '[',
        regexp_replace (
        regexp_replace (
            regexp_replace (
                regexp_replace (option_list, '---(\r|\n)-', '', 'g'),
                '(\r|\n)-',
                ',',
                'g'
            ),
            '\r|\n',
            '',
            'g'
        ),
        '''',
        '"',
        'g'),
        ']'
    ),
    remove_data = concat (
        '[',
        regexp_replace (
        regexp_replace (
            regexp_replace (
                regexp_replace (remove_data, '---(\r|\n)-', '', 'g'),
                '(\r|\n)-',
                ',',
                'g'
            ),
            '\r|\n',
            '',
            'g'
        ),
        '''',
        '"',
        'g'),
        ']'
    )
WHERE
    option_list LIKE '---%';
      SQL
    end
  end
  # rubocop:enable Metrics/MethodLength

  def down
    # Add rollback logic if needed
  end
end
