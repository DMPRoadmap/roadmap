module Dmpopidor
  module Models
    module Plan



      # CHANGE : Fix to creator display
      def owner
        usr_id = ::Role.where(plan_id: id, active: true)
                      .creator
                      .order(:created_at)
                      .pluck(:user_id).first
        if usr_id.nil?
          usr_id = ::Role.where(plan_id: id, active: true)
                        .administrator
                        .order(:created_at)
                        .pluck(:user_id).first
        end
        ::User.find(usr_id)
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
        question = ::Question.find(qid)
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

      # determines if the plan is reviewable by the specified user
      #
      # user_id - The Integer id for the user
      #
      # Returns Boolean
      # CHANGES : Reviewer can be from a different org of the plan owner
      def reviewable_by?(user_id)
        reviewer = ::User.find(user_id)
        feedback_requested? &&
        reviewer.present? &&
        reviewer.can_review_plans?
      end

      ##
      # Sets up the plan for feedback:
      #  emails confirmation messages to owners
      #  emails org admins and org contact
      #  adds org admins to plan with the 'reviewer' Role
      # CHANGES : Added feedback_requestor & request_date columns
      # def request_feedback(user)
      #   ::Plan.transaction do
      #     begin
      #       self.feedback_requested = true
      #       self.feedback_requestor = user
      #       self.feedback_request_date = DateTime.current()
      #       if save!
      #         # Send an email to the org-admin contact
      #         if user.org.contact_email.present?
      #           contact = ::User.new(email: user.org.contact_email,
      #                             firstname: user.org.contact_name)
      #           UserMailer.feedback_notification(contact, self, user).deliver_now
      #         end
      #         return true
      #       else
      #         return false
      #       end
      #     rescue Exception => e
      #       Rails.logger.error e
      #       return false
      #     end
      #   end
      # end

      ##
      # Finalizes the feedback for the plan: Emails confirmation messages to owners
      # sets flag on plans.feedback_requested to false removes org admins from the
      # 'reviewer' Role for the Plan.
      # CHANGES : Added feedback_requestor & request_date columns
      # def complete_feedback(org_admin)
      #  ::Plan.transaction do
      #     begin
      #       self.feedback_requested = false
      #       self.feedback_requestor = nil
      #       self.feedback_request_date = nil
      #       if save!
      #         # Send an email confirmation to the owners and co-owners
      #         deliver_if(recipients: owner_and_coowners,
      #                   key: "users.feedback_provided") do |r|
      #                       UserMailer.feedback_complete(
      #                         r,
      #                         self,
      #                         org_admin).deliver_now
      #                     end
      #         true
      #       else
      #         false
      #       end
      #     rescue ArgumentError => e
      #       Rails.logger.error e
      #       false
      #     end
      #   end
      # end

      # The number of research outputs for a plan.
      #
      # Returns Integer
      def num_research_outputs
        research_outputs.count
      end
    end 
  end
end