# frozen_string_literal: true

module Dmpopidor


  module Plan

    include DynamicFormHelper

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
      answer = answers.select { |a| a.question_id == qid && a.research_output_id == roid }
                      .max { |a, b| a.created_at <=> b.created_at }
      if answer.nil? && create_if_missing
        question           = ::Question.find(qid)
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
    #     rescue StandardError => e
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
    #   ::Plan.transaction do
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

    # Return the JSON Fragment linked to the Plan
    #
    # Returns JSON
    def json_fragment
      Fragment::Dmp.where("(data->>'plan_id')::int = ?", id).first
    end

    def create_plan_fragments
      template_locale = template.locale.eql?("en_GB") ? "eng" : "fra"
      plan_owner = owner
      I18n.with_locale template.locale do
        dmp_fragment = Fragment::Dmp.create(
          data: {
            "plan_id" => id
          },
          madmp_schema: MadmpSchema.find_by(name: "DMPStandard"),
          additional_info: {}
        )

        #################################
        # PERSON & CONTRIBUTORS FRAGMENTS
        #################################

        person_data = if plan_owner.present?
                        {
                          "nameType" => _("Personal"),
                          "lastName" => plan_owner.surname,
                          "firstName" => plan_owner.firstname,
                          "mbox" => plan_owner.email
                        }
                      end

        person = Fragment::Person.create(
          data: person_data || {},
          dmp_id: dmp_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: "PersonStandard"),
          additional_info: { property_name: "person" }
        )

        dmp_coordinator = Fragment::Contributor.create(
          data: {
            "person" => { "dbid" => person.id },
            "role" => _("DMP manager")
          },
          dmp_id: dmp_fragment.id,
          parent_id: nil,
          madmp_schema: MadmpSchema.find_by(name: "DMPCoordinator"),
          additional_info: { property_name: "contact" }
        )

        project_coordinator = Fragment::Contributor.create(
          data: {
            "person" => { "dbid" => person.id },
            "role" => _("Project coordinator")
          },
          dmp_id: dmp_fragment.id,
          parent_id: nil,
          madmp_schema: MadmpSchema.find_by(name: "PrincipalInvestigator"),
          additional_info: { property_name: "principalInvestigator" }
        )

        #################################
        # META & PROJECT FRAGMENTS
        #################################

        project = Fragment::Project.create(
          data: {
            "title" => title,
            "description" => description,
            "principalInvestigator" => { "dbid" => project_coordinator.id }
          },
          dmp_id: dmp_fragment.id,
          parent_id: dmp_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: "ProjectStandard"),
          additional_info: { property_name: "project" }
        )
        project.instantiate

        meta = Fragment::Meta.create(
          data: {
            "title" => _("\"%{project_title}\" project DMP") % { project_title: title },
            "creationDate" => created_at.strftime("%F"),
            "lastModifiedDate" => updated_at.strftime("%F"),
            "dmpLanguage" => template_locale,
            "dmpId" => identifier,
            "contact" => { "dbid" => dmp_coordinator.id }
          },
          dmp_id: dmp_fragment.id,
          parent_id: dmp_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: "MetaStandard"),
          additional_info: { property_name: "meta" }
        )
        meta.instantiate

        dmp_coordinator.update(parent_id: meta.id)
        project_coordinator.update(parent_id: project.id)
      end
    end

    def copy_plan_fragments(plan)
      create_plan_fragments if json_fragment.nil?

      incoming_dmp = plan.json_fragment
      raw_project = incoming_dmp.project.get_full_fragment
      raw_meta = incoming_dmp.meta.get_full_fragment
      raw_meta = raw_meta.merge(
        "title" => "Copy of " + raw_meta["title"]
      )

      json_fragment.project.raw_import(raw_project, json_fragment.project.madmp_schema)
      json_fragment.meta.raw_import(raw_meta, json_fragment.meta.madmp_schema)
    end

  end

end
