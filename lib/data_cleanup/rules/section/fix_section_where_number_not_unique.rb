# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix section where number not unique on Section
    module Section
      class FixSectionWhereNumberNotUnique < Rules::Base

        def description
          "Section: Reorder sections in phase, where number(order) is not unique"
        end

        def call
          invalid_sections = ::Section.all.reject(&:valid?)
          # Get the phases associated to the invalid sections
          phases = ::Phase.where(id: invalid_sections.collect(&:phase_id).uniq)

          phases.each do |p| 
            # Get associated sections, order by number
            ss = p.sections.order(:number)

            # Reorder sections
            ss.each_with_index do |s, idx|
              s.update_attribute('number', idx + 1)
            end
          end

        end
      end
    end
  end
end
