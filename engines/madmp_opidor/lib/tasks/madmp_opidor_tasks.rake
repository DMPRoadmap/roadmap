# frozen_string_literal: true

namespace :madmp_opidor do
  desc 'Generate swagger files from specs'
  task :swaggerize do
    ENV['PATTERN'] = 'engines/madmp_opidor/spec/**/*_spec.rb'
    Rake::Task['rswag:specs:swaggerize'].invoke
  end
end
