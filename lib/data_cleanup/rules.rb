# frozen_string_literal: true

<<<<<<< HEAD
if File.exist?(Rails.root.join("lib", "data_cleanup", "rules", "base.rb"))
  require_relative "rules/base"
end

module DataCleanup

  module Rules

  end

=======
require_relative 'rules/base' if File.exist?(Rails.root.join('lib', 'data_cleanup', 'rules', 'base.rb'))

module DataCleanup
  # Think this is used for RSpec
  module Rules
  end
>>>>>>> upstream/master
end
