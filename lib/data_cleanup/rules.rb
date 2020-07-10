# frozen_string_literal: true

if File.exist?(Rails.root.join("lib", "data_cleanup", "rules", "base.rb"))
  require_relative "rules/base"
end

module DataCleanup

  module Rules

  end

end
