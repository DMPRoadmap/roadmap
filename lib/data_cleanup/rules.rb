# frozen_string_literal: true

require_relative 'rules/base' if Rails.root.join('lib', 'data_cleanup', 'rules', 'base.rb').exist?

module DataCleanup
  # Think this is used for RSpec
  module Rules
  end
end
