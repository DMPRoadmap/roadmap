# frozen_string_literal: true

require "text"

# rubocop:disable Metrics/BlockLength
namespace :config do

  desc "Determine where all of the local config values are coming from"
  task trace: :environment do
    p "Tracing Config Variables:"
    p "---------------------------------------------------"
    p ""
    pp DmproadmapConfig.new.to_source_trace
  end

  desc "Dump rails configs which were discovered by Anyway::Config classes"
  task dump: :environment do
      p "Dumping config.x.:"
      p "---------------------------------------------------"
      pp Rails.application.config.x
  end

end
