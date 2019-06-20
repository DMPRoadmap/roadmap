module Dmpopidor
  module Models
    module Phase
      # CHANGES : ADDED RESEARCH OUTPUT SUPPORT
      def visibility_allowed?(plan)
        num_answered = num_answered_questions(plan) / plan.num_research_outputs
        value = Rational(num_answered, plan.num_questions) * 100
        value >= Rails.application.config.default_plan_percentage_answered.to_f
      end
    end 
  end
end