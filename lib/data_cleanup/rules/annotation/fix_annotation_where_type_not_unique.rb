# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix annotation where type not unique on Annotation
    module Annotation
      class FixAnnotationWhereTypeNotUnique < Rules::Base

        def description
          "(ACTIVATE LAST) Annotation: Delete association where the type is not unique for a given question"
        end

        def call
          # # Get all invalid Annotations
          # invalid_annotations = ::Annotation.all.reject(&:valid?)
          
          # invalid_annotations.each do |a| 
          #     # Checks if the updated_at value is equal to the min updated_at value 
          #     # for the annotations with the same question & type
          #     # Delete it if true
          #     # Logs the deleted
          #     if a.updated_at == ::Annotation.where("question_id = ? AND type = ? ", a.question_id, ::Annotation.types[a.type]).minimum(:updated_at)
          #      p "Deleted Annotation (" + a.id.to_s + "):'" + a.text + "' "  +
          #        "Question (" + a.question_id.to_s + "): '" + a.question.text + "' " + 
          #        "Template (" + a.template.id.to_s + "): '" + a.template.title + "'"
          #      a.delete
          #     end
            
          # end
        end
      end
    end
  end
end
