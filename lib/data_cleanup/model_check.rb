# frozen_string_literal: true
module DataCleanup
  # Checks whether all records for a given model are valid or not
  class ModelCheck

    require_relative "reporting"

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def call
      rule, models = ARGV[1].to_s.split("=")
      case rule
      when 'INCLUDE'
        return unless model.model_name.in?(models.split(","))
      when 'EXCLUDE'
        return if model.model_name.in?(models.split(","))
      end
      DataCleanup.logger.info "Checking #{model.model_name.plural}:"
      model.find_in_batches do |batch|
        instance_check = InstanceCheck.new
        batch.each { |instance| instance_check.(instance) }
      end
      DataCleanup.logger.info ""
    end
  end
end
