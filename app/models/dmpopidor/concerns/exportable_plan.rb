# frozen_string_literal: true

module Dmpopidor

  module Concerns

    module ExportablePlan

      # CHANGES : Research Outputs support
      def prepare(user, coversheet = false)
        hash = coversheet ? prepare_coversheet : {}
        template = Template.includes(phases: { sections: { questions: :question_format } })
                           .joins(phases: { sections: { questions: :question_format } })
                           .where(id: template_id)
                           .order("sections.number", "questions.number").first
        hash[:customization] = template.customization_of.present?
        hash[:title] = title
        hash[:answers] = answers
        hash[:research_outputs] = research_outputs

        # add the relevant questions/answers
        phases = []
        template.phases.order(:number).each do |phase|
          phs = { id: phase.id, title: phase.title, number: phase.number, sections: [] }
          phase.sections.order(:number).each do |section|
            sctn = { id: section.id,
                     title: section.title,
                     number: section.number,
                     questions: [],
                     modifiable: section.modifiable }
            section.questions.each do |question|
              txt = question.text
              sctn[:questions] << {
                id: question.id,
                text: txt,
                format: question.question_format
              }
            end
            phs[:sections] << sctn
          end
          phases << phs
        end
        hash[:phases] = phases

        record_plan_export(user, :pdf)

        hash
      end

      # CHANGES : Users departments in coversheet
      # rubocop:disable Metrics/AbcSize
      def prepare_coversheet
        hash = {}
        # name of owner and any co-owners
        attribution = owner.present? ? [owner.name(false)] : []
        self.roles.administrator.not_creator.each do |role|
          attribution << role.user.name(false)
        end
        hash[:attribution] = attribution

        # Org name of plan owner's org
        hash[:affiliation] = owner.present? ? owner.org.name : ""
        hash[:affiliation] += owner.present? && owner.department ? " - #{owner.department.name}" : ""

        # set the funder name
        hash[:funder] = funder.name if funder.present?
        template_org = template.org
        hash[:funder] = template_org.name if !hash[:funder].present? && template_org.funder?

        # set the template name and customizer name if applicable
        hash[:template] = template.title
        customizer = ""
        cust_questions = questions.where(modifiable: true).pluck(:id)
        # if the template is customized, and has custom answered questions
        if template.customization_of.present? &&
           Answer.where(plan_id: id, question_id: cust_questions).present?
          customizer = _(" Customised By: ") + template.org.name
        end
        hash[:customizer] = customizer
        hash
      end
      # rubocop:enable Metrics/AbcSize

    end

  end

end
