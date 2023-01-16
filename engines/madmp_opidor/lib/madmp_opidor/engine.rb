# frozen_string_literal: true

module MadmpOpidor
  class Engine < ::Rails::Engine
    require 'json'
    require 'active_record'
    require 'activerecord-import'
  end
end
