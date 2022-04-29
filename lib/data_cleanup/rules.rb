# frozen_string_literal: true

require_relative 'rules/base' if File.exist?(Rails.root.join('lib', 'data_cleanup', 'rules', 'base.rb'))

module DataCleanup
  # Think this is used for RSpec
  module Rules
  end
end
