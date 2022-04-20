# frozen_string_literal: true

<<<<<<< HEAD
require_relative "data_cleanup/model_check"
require_relative "data_cleanup/instance_check"
require_relative "data_cleanup/reporting"
require_relative "data_cleanup/rules"

module DataCleanup

=======
require_relative 'data_cleanup/model_check'
require_relative 'data_cleanup/instance_check'
require_relative 'data_cleanup/reporting'
require_relative 'data_cleanup/rules'

# Some legacy cleanup helpers
module DataCleanup
>>>>>>> upstream/master
  COLOR_CODES = { red: 31, green: 32 }.freeze

  module_function

  def logger
<<<<<<< HEAD
    @logger ||= Logger.new(Rails.root.join("log", "validations.log"))
=======
    @logger ||= Logger.new(Rails.root.join('log', 'validations.log'))
>>>>>>> upstream/master
  end

  def display(message, inline: false, color: nil)
    message = "#{message}\n" unless inline
    message = "\e[#{COLOR_CODES[color]}m#{message}\e[0m" if color
    print message
  end
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
