module ExportablePlan
  extend ActiveSupport::Concern
  
  included do
    
    def as_pdf(coversheet = false)
      prepare(coversheet)
    end
    
    private 
      def prepare(coversheet = false)
        hash = coversheet ? prepare_coversheet : {}
        template = Template.includes(phases: { sections: {questions: :question_format } }).
                            joins(phases: { sections: { questions: :question_format } }).
                            where(id: self.template_id).first
        
        hash[:title] = self.title
        hash[:answers] = self.answers
        
        # add the relevant questions/answers
        phases = []
        template.phases.each do |phase|
          phs = { title: phase.title, number: phase.number, sections: [] }
          phase.sections.each do |section|
            sctn = { title: section.title, number: section.number, questions: [] }
            section.questions.each do |question|
              txt = []
              if question.question_format.option_based?
                opts = QuestionOption.where(question_id: question.id)
                opts.each do |opt|
                  txt << opt.text
                end
              else
                txt << question.text
              end
              sctn[:questions] << { id: question.id, text: txt }
            end
            phs[:sections] << sctn
          end
          phases << phs
        end
        hash[:phases] = phases
        
        record_plan_export(:pdf)
        
        hash
      end
    
      def prepare_coversheet
        hash = {}
        # name of owner and any co-owners
        attribution = self.owner.present? ? [self.owner.name(false)] : []
        self.roles.administrator.not_creator.each do |role|
          attribution << role.user.name(false)
        end
        hash[:attribution] = attribution
        
        # Org name of plan owner's org
        hash[:affiliation] = self.owner.present? ? self.owner.org.name : ''
        
        # set the funder name
        hash[:funder] = self.funder_name.present? ? self.funder_name : (self.template.org.present? ? self.template.org.name : '')

        # set the template name and customizer name if applicable
        hash[:template] = self.template.title
        customizer = ""
        cust_questions = self.questions.where(modifiable: true).pluck(:id)
        # if the template is customized, and has custom answered questions
        if self.template.customization_of.present? && Answer.where(plan_id: self.id, question_id: cust_questions).present?
          customizer = _(" Customised By: ") + self.template.org.name
        end
        hash[:customizer] = customizer
        hash
      end
    
      def record_plan_export(format)
        exported_plan = ExportedPlan.new.tap do |ep|
          ep.plan = self
          ep.phase_id = self.phases.first.id
          ep.format = format
          plan_settings = self.settings(:export)

          Settings::Template::DEFAULT_SETTINGS.each do |key, value|
            ep.settings(:export).send("#{key}=", plan_settings.send(key))
          end
        end
        exported_plan.save
      end
  end
end