# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix duplicate type on Annotation
    module Annotation

      class FixDuplicateType < Rules::Base

        def description
          "Fix duplicate type on Annotation"
        end

        def call
          ::Annotation.group(:question_id, :type, :org_id)
                      .count
                      .select { |k,v| v > 1 }
                      .each do |array, count|

            question_id = array.first
            type        = array.second
            org_id      = array.third

            log("Destroying all duplicate Annotations with question_id: #{question_id} "\
                "type: #{type} and org_id: #{org_id}")

            ::Annotation.where(question_id: question_id, type: type, org_id: org_id)
                        .order(updated_at: :desc)
                        .offset(1)
                        .destroy_all
          end
        end

      end

    end
  end
end
