# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix duplicate number on Section
    module Section
      class FixDuplicateNumber < Rules::Base

        def description
          "Fix duplicate number on Section"
        end

        def call
          data = ::Section.group(:number, :phase_id)
                          .count
                          .select { |k,v| v > 1 }
          data.each do |values, count|
            number, phase_id = *values
            ids = ::Section.where(phase_id: phase_id)
                           .order("number ASC, created_at ASC")
                           .pluck(:id)
            phase = ::Phase.find(phase_id)
            ::Section.update_numbers!(*ids, parent: phase)
          end
        end
      end
    end
  end
end
