# frozen_string_literal: true

require 'objspace'

namespace :memory_leak do
  desc 'Dump the current ObjectSpace'
  task dump_objects: :environment do
    file = File.open(Rails.root.join('log', "object_dump_#{Time.now.strftime('%Y_%m_%d-%H_%M')}.log"), 'w+')
    pp ObjectSpace.dump_all(output: file)
  end
end
