module DMPRoadmap
  # Base configuration for the DMPRoadmap system
  # rubocop:disable Layout/LineLength
  class Application < Rails::Application
    # --------------------- #
    # ORGANISATION SETTINGS #
    # --------------------- #

    # The memory usage log file that will be used by ApplicationController and ApplicationRecord
    memory_logger = -> (msg) do
      file_name = Rails.root.join('log', "memory_utilization_#{Time.now.strftime('%Y-%m-%d')}.log")
      file = File.open(file_name, File.exists?(file_name) ? 'a' : 'w+')
      file.write(msg)
      file.close
    end

    config.x.memory_usage_log = memory_logger
  end
end
