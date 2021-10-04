# frozen_string_literal: true

require_relative 'rules/base' if File.exist?(Rails.root.join('lib', 'data_cleanup', 'rules', 'base.rb'))

module DataCleanup
  module Rules
  end
end
