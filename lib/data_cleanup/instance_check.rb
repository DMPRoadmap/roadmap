# frozen_string_literal: true

require_relative "reporting"

module DataCleanup

  # Check whether a given database record is valid or not
  class InstanceCheck

    def call(instance)
      DataCleanup.logger.info("Checking #{instance.class}##{instance.id}...")
      Reporting.total_record_count += 1
      begin
        if instance.invalid?
          DataCleanup.logger.info(<<~TEXT)
            Instance #{instance.class}##{instance.id} invalid!
            Errors: #{instance.errors.full_messages.to_sentence}
          TEXT
          Reporting.invalid_record_count += 1
          Reporting.invalid_records << instance
          DataCleanup.display("F", inline: true)
        else
          DataCleanup.logger.info("Instance #{instance.class}##{instance.id} valid!")
          DataCleanup.display(".", inline: true)
        end
      rescue Dragonfly::Job::Fetch::NotFound
        DataCleanup.display(".", inline: true)
      end
    end
    # rubocop:enable

  end

end
