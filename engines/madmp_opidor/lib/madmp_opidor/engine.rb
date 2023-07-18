# frozen_string_literal: true

module MadmpOpidor
  # MadmpOpidor engine : contains the DMP OPIDoR code for the dynamic form features
  class Engine < ::Rails::Engine
    require 'json'
    require 'active_record'
    require 'activerecord-import'
  end
end
