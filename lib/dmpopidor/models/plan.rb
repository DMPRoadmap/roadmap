# frozen_string_literal: true

module Dmpopidor

  module Models

    module Plan

      include DynamicFormHelper

      # CHANGE : Fix to creator display
      def owner
        usr_id = ::Role.where(plan_id: id, active: true)
                       .administrator
                       .order(:created_at)
                       .pluck(:user_id).first
        usr_id.present? ? ::User.find(usr_id) : nil
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
      def request_feedback(user)
        ::Plan.transaction do
          begin
            self.feedback_requested = true
            self.feedback_requestor = user
            self.feedback_request_date = DateTime.current()
            if save!
              # Send an email to the org-admin contact
              if user.org.contact_email.present?
                contact = ::User.new(email: user.org.contact_email,
                                  firstname: user.org.contact_name)
                UserMailer.feedback_notification(contact, self, user).deliver_now
              end
              return true
            else
              return false
            end
          rescue Exception => e
            Rails.logger.error e
            return false
          end
        end
      end

      ##
      # Finalizes the feedback for the plan: Emails confirmation messages to owners
      # sets flag on plans.feedback_requested to false removes org admins from the
      # 'reviewer' Role for the Plan.
      # CHANGES : Added feedback_requestor & request_date columns
      def complete_feedback(org_admin)
        ::Plan.transaction do
          begin
            self.feedback_requested = false
            self.feedback_requestor = nil
            self.feedback_request_date = nil
            if save!
              # Send an email confirmation to the owners and co-owners
              deliver_if(recipients: owner_and_coowners,
                        key: "users.feedback_provided") do |r|
                            UserMailer.feedback_complete(
                              r,
                              self,
                              org_admin).deliver_now
                          end
              true
            else
              false
            end
          rescue ArgumentError => e
            Rails.logger.error e
            false
          end
        end
      end

      # The number of research outputs for a plan.
      #
      # Returns Integer
      def num_research_outputs
        research_outputs.count
      end

      # Return the JSON Fragment linked to the Plan
      #
      # Returns JSON
      def json_fragment
        Fragment::Dmp.where("(data->>'plan_id')::int = ?", id).first
      end

      def create_plan_fragments
        dmp_fragment = Fragment::Dmp.create(
          data: {
            "plan_id" => id
          },
          madmp_schema: MadmpSchema.find_by(name: "DMPStandard"),
          additional_info: {}
        )

        project = Fragment::Project.create(
          data: {
            "title" => title
          },
          dmp_id: dmp_fragment.id,
          parent_id: dmp_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: "ProjectStandard"),
          additional_info: {}
        )
        project.instantiate

        meta = Fragment::Meta.create(
          data: {
            "title" => d_("dmpopidor", "\"%{project_title}\" project DMP") % { project_title: title },
            "creationDate" => created_at.strftime("%F"),
            "lastModifiedDate" => updated_at.strftime("%F"),
            "dmpLanguage" => template.locale
          },
          dmp_id: dmp_fragment.id,
          parent_id: dmp_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: "MetaStandard"),
          additional_info: {}
        )
        meta.instantiate

        person_data = {
          "lastName" => owner.surname,
          "firstName" => owner.firstname,
          "mbox" => owner.email
        } unless owner.nil?
        person = Fragment::Person.create(
          data: person_data || {},
          dmp_id: dmp_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: "PersonStandard"),
          additional_info: { property_name: "person" }
        )

        Fragment::Contributor.create(
          data: {
            "person" => { "dbid" => person.id },
            "role" => d_("dmpopidor", "DMP coordinator")
          },
          dmp_id: dmp_fragment.id,
          parent_id: meta.id,
          madmp_schema: MadmpSchema.find_by(name: "DMPCoordinator"),
          additional_info: { property_name: "contact" }
        )

        Fragment::Contributor.create(
          data: {
            "person" => { "dbid" => person.id },
            "role" => d_("dmpopidor", "Project coordinator")
          },
          dmp_id: dmp_fragment.id,
          parent_id: project.id,
          madmp_schema: MadmpSchema.find_by(name: "PrincipalInvestigator"),
          additional_info: { property_name: "principalInvestigator" }
        )
      end

      def update_plan_fragments(meta, project)
        dmp_fragment = json_fragment
        meta_fragment = dmp_fragment.meta
        project_fragment = dmp_fragment.project

        meta_data = data_reformater(
          meta_fragment.madmp_schema.schema,
          meta,
          meta_fragment.classname
        )

        project_data = data_reformater(
          project_fragment.madmp_schema.schema,
          project,
          project_fragment.classname
        )

        meta_fragment.save_as_multifrag(meta_data, meta_fragment.madmp_schema)
        project_fragment.save_as_multifrag(project_data, project_fragment.madmp_schema)
      end

    end

  end

end
