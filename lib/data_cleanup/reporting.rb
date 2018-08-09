module DataCleanup
  # Report the status of the data validations after checks have been run.
  module Reporting
    mattr_accessor :total_record_count
    mattr_accessor :invalid_record_count
    mattr_accessor :invalid_records
    mattr_accessor :issues_found

    self.total_record_count   = 0
    self.invalid_record_count = 0
    self.invalid_records      = []
    self.issues_found         = []

    module_function

    # Prepare the report for printing to log and STDOUT
    def prepare!
      invalid_records.each do |record|
        record.errors.full_messages.each do |issue|
          desc = "#{record.class.model_name} was invalid: #{issue}"
          issues_found << desc unless issues_found.include?(desc)
        end
      end
    end

    def report
      issues_found.each { |issue| DataCleanup.logger.info issue }
      color = invalid_record_count.zero? ? :green : :red
      DataCleanup.logger.info(<<~TEXT, color: color)
        Invalid records: #{invalid_record_count} / #{total_record_count}
      TEXT
    end
  end
end
