module ExportablePlan
  extend ActiveSupport::Concern

  included do

    def as_pdf(coversheet = false)
      prepare(coversheet)
    end

    def as_csv(headings = true, unanswered = true)
      hash = prepare(false)

      CSV.generate do |csv|
        hdrs = (hash[:phases].length > 1 ? [_('Phase')] : [])
        if headings
          hdrs << [_('Section'),_('Question'),_('Answer')]
        else
          hdrs << [_('Answer')]
        end

        csv << hdrs.flatten
        hash[:phases].each do |phase|
          phase[:sections].each do |section|
            section[:questions].each do |question|
              answer = self.answer(question[:id], false)
              answer_text = answer.present? ? answer.text : (unanswered ? 'Not Answered' : '')
              flds = (hash[:phases].length > 1 ? [phase[:title]] : [])
              if headings
                if question[:text].is_a? String
                  question_text = question[:text]
                else
                  question_text = (question[:text].length > 1 ? question[:text].join(', ') : question[:text][0])
                end
                flds << [ section[:title], sanitize_text(question_text), sanitize_text(answer_text) ]
              else
                flds << [ sanitize_text(answer_text) ]
              end

              csv << flds.flatten
            end
          end
        end
      end
    end

    private
      def prepare(coversheet = false)
        hash = coversheet ? prepare_coversheet : {}
        template = Template.includes(phases: { sections: {questions: :question_format } }).
                            joins(phases: { sections: { questions: :question_format } }).
                            where(id: self.template_id).order('sections.number', 'questions.number').first

        hash[:title] = self.title
        hash[:answers] = self.answers

        # add the relevant questions/answers
        phases = []
        template.phases.each do |phase|
          phs = { title: phase.title, number: phase.number, sections: [] }
          phase.sections.each do |section|
            sctn = { title: section.title, number: section.number, questions: [] }
            section.questions.each do |question|
              txt = question.text
              sctn[:questions] << { id: question.id, text: txt, format: question.question_format }
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

      def sanitize_text(text)
        if (!text.nil?) then ActionView::Base.full_sanitizer.sanitize(text.gsub(/&nbsp;/i,"")) end
      end
  end
end
