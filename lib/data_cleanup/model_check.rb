# frozen_string_literal: true

module DataCleanup
<<<<<<< HEAD

  # Checks whether all records for a given model are valid or not
  class ModelCheck

    require_relative "reporting"
=======
  # Checks whether all records for a given model are valid or not
  class ModelCheck
    require_relative 'reporting'
>>>>>>> upstream/master

    attr_reader :model

    def initialize(model)
      @model = model
    end

<<<<<<< HEAD
    def call
      return unless model.superclass == ActiveRecord::Base

      rule, models = ARGV[1].to_s.split("=")
      case rule
      when "INCLUDE"
        return unless model.model_name.in?(models.split(","))
      when "EXCLUDE"
        return if model.model_name.in?(models.split(","))
=======
    # rubocop:disable Metrics/AbcSize
    def call
      return unless model.superclass == ActiveRecord::Base

      rule, models = ARGV[1].to_s.split('=')
      case rule
      when 'INCLUDE'
        return unless model.model_name.in?(models.split(','))
      when 'EXCLUDE'
        return if model.model_name.in?(models.split(','))
>>>>>>> upstream/master
      end
      DataCleanup.display "Checking #{model.model_name.plural}:"
      model.find_in_batches do |batch|
        instance_check = InstanceCheck.new
        batch.each { |instance| instance_check.call(instance) }
      end
<<<<<<< HEAD
      DataCleanup.display ""
    end
    # rubocop:enable

  end

=======
      DataCleanup.display ''
    end
    # rubocop:enable Metrics/AbcSize
  end
>>>>>>> upstream/master
end
