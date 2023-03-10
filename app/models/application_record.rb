# frozen_string_literal: true

# Base ActiveRecord object
class ApplicationRecord < ActiveRecord::Base
  include GlobalHelpers
  include ValidationValues
  include ValidationMessages

  self.abstract_class = true

  class << self
    # Indicates whether the underlying DB is MySQL
    def mysql_db?
      connection.adapter_name == 'Mysql2'
    end

    def postgres_db?
      connection.adapter_name == 'PostgreSQL'
    end

    # Generates the appropriate where clause for a JSON field based on the DB type
    def safe_json_where_clause(column:, hash_key:)
      return "(#{column}->>'#{hash_key}' LIKE ?)" unless mysql_db?

      "(#{column}->>'$.#{hash_key}' LIKE ?)"
    end

    # Generates the appropriate where clause for a regular expression based on the DB type
    def safe_regexp_where_clause(column:)
      return "#{column} ~* ?" unless mysql_db?

      "#{column} REGEXP ?"
    end
  end

  def sanitize_fields(*attrs)
    attrs.each do |attr|
      send("#{attr}=", ActionController::Base.helpers.sanitize(send(attr)))
    end
  end
end
