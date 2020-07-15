# frozen_string_literal: true

require_relative "data_cleanup/model_check"
require_relative "data_cleanup/instance_check"
require_relative "data_cleanup/reporting"
require_relative "data_cleanup/rules"

module DataCleanup

  COLOR_CODES = { red: 31, green: 32 }.freeze

  module_function

  def logger
    @logger ||= Logger.new(Rails.root.join("log", "validations.log"))
  end

  def display(message, inline: false, color: nil)
    message = "#{message}\n" unless inline
    message = "\e[#{COLOR_CODES[color]}m#{message}\e[0m" if color
    print message
  end

end
