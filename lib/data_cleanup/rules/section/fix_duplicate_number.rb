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
          # A set of unique phase_ids that contain Sections with duplicate numbers
          phase_ids = ::Section.group(:number, :phase_id)
                               .count
                               .select { |k,v| v > 1 }
                               .collect { |values, count| values.last }
                               .uniq

          phase_ids.each do |phase_id|
            log("Re-setting number order for Sections in Phase##{phase_id}")
            phase = ::Phase.find(phase_id)
            sorted_sections = SectionSorter.new(*phase.sections).sort!
            ::Section.update_numbers!(*sorted_sections.map(&:id), parent: phase)
          end
        end

      end
    end
  end
end
