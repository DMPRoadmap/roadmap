# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix phase where number not unique on Phase
    module Phase
      class FixPhaseWhereNumberNotUnique < Rules::Base

        def description
          "Phase: Reorder phases in template, where number(order) is not unique"
        end

        def call
          invalid_phases = ::Phase.all.reject(&:valid?)
          # Get the templates associated to the invalid phases
          templates = ::Template.where(id: invalid_phases.collect(&:template_id).uniq)

          templates.each do |t| 
            # Get associated phases, order by number
            ps = t.phases.order(:number)

            # Reorder sections
            ps.each_with_index do |ph, idx|
              ph.update_attribute('number', idx + 1)
            end
          end
        end
      end
    end
  end
end
