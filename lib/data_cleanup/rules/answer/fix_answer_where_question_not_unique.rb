# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix answer where question not unique on Answer
    module Answer
      class FixAnswerWhereQuestionNotUnique < Rules::Base

        def description
          "(ACTIVATE LAST) Answer: Delete answers where the question is not unique for a given plan"
        end

        def call
        #   # Get all invalid Answers
        #   invalid_answers = ::Answer.all.reject(&:valid?)

        #   invalid_answers.each do |a| 
        #     # Checks if the updated_at value is equal to the min updated_at value 
        #     # for the answers with the same question & plan
        #     # Delete it if true
        #     # Logs the deleted
        #     if a.updated_at == ::Answer.where("question_id = ? AND plan_id = ? ", a.question_id, a.plan_id).minimum(:updated_at)
        #      p "Deleted Answer (" + (a.id.to_s if a.id)  + "):'" + a.text + "' "  +
        #        "Question (" + (a.question_id.to_s if a.question_id) + "): '" + a.question.text + "' " + 
        #        "Plan (" + (a.plan.id.to_s if a.plan.id )+ "): '" + a.plan.title + "'"
        #      a.delete
        #     end
        #  end
        end
      end
    end
  end
end
