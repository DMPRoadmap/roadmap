module Dmpopidor
  module Models
    module Phase
      # CHANGES : ADDED DATASET SUPPORT
      def visibility_allowed?(plan)
        num_answered = num_answered_questions(plan) / plan.num_datasets
        value = Rational(num_answered, plan.num_questions) * 100
        value >= Rails.application.config.default_plan_percentage_answered.to_f
      end
    end 
  end
end