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
            phase    = ::Phase.find(phase_id)
            sections = phase.sections

            # When every section within a Phase is modifiable, or when none is...
            if sections.all?(&:modifiable?) || sections.all?(&:template?)
              update_homogenous_set(phase)

            # When some of the sections are modifiable then...
            else
              update_heterogenous_set(phase)
            end
          end
        end

        private

        # Re-sort the Phase's Sections by number, then by the ID
        def update_homogenous_set(phase)
          ids = phase.sections.order("number ASC, id ASC").ids
          ::Section.update_numbers!(*ids, parent: phase)
        end

        def update_heterogenous_set(phase)
          # Array of duplicate Section numbers within this Phase
          numbers = phase.sections
                         .group(:number)
                         .count
                         .select { |number, count| count > 1 }
                         .collect(&:first)

          # If there are duplicates in the #1 position
          if numbers.include?(1)
            # There should only be, if any, one prefixed modifiable Section
            prefix  = phase.sections.modifiable.where(number: 1).limit(1).ids

            # In the off-chance that there is more than one prefix Section, stick them
            # after the  unmodifiable block
            erratic = phase.sections.modifiable.where(number: 1).offset(1).ids

            # Collect the unmodifiable Section ids in the order the should be displayed
            unmodifiable = phase.sections.not_modifiable.order('number, id').ids

            # Then any additional Sections that come after the main block...
            modifiable = phase.sections.modifiable.order('number, id').ids

            # Create one Array with all of the ids in the correct order.
            ids = prefix + erratic + unmodifiable + modifiable
            ::Section.update_numbers!(*ids, parent: phase)

          else
            # Sort ids based on the number order. If there are duplicates, then take the
            # earliest first. Unmodifiable sections from the template should be grouped
            # together before the additional, modifiable sections are appended afterwards.
            ids = phase.sections.not_modifiable.order("number, id").ids
            ids += phase.sections.modifiable.order("number, id").ids
            ::Section.update_numbers!(*ids, parent: phase)
          end
        end

      end
    end
  end
end
