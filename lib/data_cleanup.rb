# frozen_string_literal: true
module DataCleanup
  require_relative "data_cleanup/model_check"
  require_relative "data_cleanup/instance_check"
  require_relative "data_cleanup/reporting"
  require_relative "data_cleanup/rules"

  module_function

  def logger
    @logger ||= Logger.new(Rails.root.join("log", "validations.log"))
  end

  COLOR_CODES = { red: 31, green: 32 }

  def logger.info(message, inline: false, color: nil)
    message = message + "\n" unless inline
    if color
      message = "\e[#{COLOR_CODES[color]}m#{message}\e[0m"
    end
    super(message) unless inline
    print message
  end
end
