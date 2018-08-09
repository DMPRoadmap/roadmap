require_relative "reporting"

module DataCleanup
  # Check whether a given database record is valid or not
  class InstanceCheck
    # frozen_string_literal: true

    def call(instance)
      Reporting.total_record_count += 1
      begin
        if instance.invalid?
          Reporting.invalid_record_count += 1
          Reporting.invalid_records << instance
          DataCleanup.logger.info("F", inline: true)
        else
          DataCleanup.logger.info(".", inline: true)
        end
      rescue Dragonfly::Job::Fetch::NotFound
        DataCleanup.logger.info(".", inline: true)
      end
    end
  end
end