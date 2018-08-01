# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix duplicate number on Phase
    module Phase
      class FixDuplicateNumber < Rules::Base

        def description
          "Fix duplicate number on Phase"
        end

        def call
          data = ::Phase.group(:number, :template_id)
                        .count
                        .select { |k,v| v > 1 }
          data.each do |values, count|
            number, template_id = *values
            ids = ::Phase.where(template_id: template_id)
                         .order("number ASC, created_at ASC")
                         .pluck(:id)
            template = ::Template.find(template_id)
            ::Phase.update_numbers!(*ids, parent: template)
          end
        end
      end
    end
  end
end
