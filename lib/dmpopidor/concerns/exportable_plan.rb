# frozen_string_literal: true

module Dmpopidor

  module Concerns

    module ExportablePlan

      # CHANGES : Research Outputs support
      def prepare(coversheet = false)
        hash = coversheet ? prepare_coversheet : {}
        template = Template.includes(phases: { sections: { questions: :question_format } })
                           .joins(phases: { sections: { questions: :question_format } })
                           .where(id: self.template_id)
                           .order("sections.number", "questions.number").first
        hash[:customization] = template.customization_of.present?
        hash[:title] = self.title
        hash[:answers] = self.answers
        hash[:research_outputs] = self.research_outputs

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

        record_plan_export(:pdf)

        hash
      end

      # CHANGES : Users departments in coversheet
      def prepare_coversheet
        hash = {}
        # name of owner and any co-owners
        attribution = self.owner.present? ? [self.owner.name(false)] : []
        self.roles.administrator.not_creator.each do |role|
          attribution << role.user.name(false)
        end
        hash[:attribution] = attribution

        # Org name of plan owner's org
        hash[:affiliation] = self.owner.present? ? self.owner.org.name : ""
        hash[:affiliation] += self.owner.present? && self.owner.department ? " - #{self.owner.department.name}" : ""

        # set the funder name
        hash[:funder] = self.funder.name if self.funder.present?
        template_org = self.template.org
        hash[:funder] = template_org.name if !hash[:funder].present? && template_org.funder?

        # set the template name and customizer name if applicable
        hash[:template] = self.template.title
        customizer = ""
        cust_questions = self.questions.where(modifiable: true).pluck(:id)
        # if the template is customized, and has custom answered questions
        if self.template.customization_of.present? &&
          Answer.where(plan_id: self.id, question_id: cust_questions).present?
          customizer = _(" Customised By: ") + self.template.org.name
        end
        hash[:customizer] = customizer
        hash
      end

    end

  end

end
