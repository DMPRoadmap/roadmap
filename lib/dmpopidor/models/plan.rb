module Dmpopidor
  module Models
    module Plan



      # CHANGE : Fix to creator display
      def owner
        usr_ids = Role.where(plan_id: id, active: true)
                      .creator
                      .order(:created_at)
                      .pluck(:user_id).uniq
        User.where(id: usr_ids).first
      end

      # CHANGES : ADDED RESEARCH OUTPUT SUPPORT
      # The most recent answer to the given question id optionally can create an answer if
      # none exists.
      #
      # qid               - The id for the question to find the answer for
      # roid               - The id for the research output to find the answer for
      # create_if_missing - If true, will genereate a default answer
      #                     to the question (defaults: true).
      #
      # Returns Answer
      # Returns nil
      def answer(qid, create_if_missing = true, roid = nil)
        answer = answers.where(question_id: qid, research_output_id: roid).order("created_at DESC").first
        question = Question.find(qid)
        if answer.nil? && create_if_missing
          answer             = Answer.new
          answer.plan_id     = id
          answer.question_id = qid
          answer.text        = question.default_value
          default_options    = []
          question.question_options.each do |option|
            default_options << option if option.is_default
          end
          answer.question_options = default_options
        end
        answer
      end

      # Deactivates the plan (sets all roles to inactive and visibility to :private)
      #
      # Returns Boolean
      def deactivate!
        # If no other :creator, :administrator or :editor is attached
        # to the plan, then also deactivate all other active roles
        # and set the plan's visibility to :private
        # CHANGE : visibility setting to privately_private_visible
        if authors.size == 0
          roles.where(active: true).update_all(active: false)
          self.visibility = ::Plan.visibilities[:privately_private_visible]
          save!
        else
          false
        end
      end


      # The number of research outputs for a plan.
      #
      # Returns Integer
      def num_research_outputs
        research_outputs.count
      end
    end 
  end
end