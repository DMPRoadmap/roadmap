# frozen_string_literal: true

module ExportablePlan

  include ConditionsHelper

  def as_pdf(coversheet = false)
    prepare(coversheet)
  end

  def as_csv(headings = true,
             unanswered = true,
             selected_phase = nil,
             show_custom_sections = true,
             show_coversheet = false)
    hash = prepare(show_coversheet)
    CSV.generate do |csv|
      if show_coversheet
        prepare_coversheet_for_csv(csv, headings, hash)
      end

      hdrs = (hash[:phases].many? ? [_("Phase")] : [])
      if headings
        hdrs << [_("Section"), _("Question"), _("Answer")]
      else
        hdrs << [_("Answer")]
      end

      customization = hash[:customization]

      csv << hdrs.flatten
      hash[:phases].each do |phase|
        if  selected_phase.nil? || phase[:title] == selected_phase.title
          phase[:sections].each do |section|
            show_section = !customization
            show_section ||= customization && !section[:modifiable]
            show_section ||= customization && section[:modifiable] && show_custom_sections

            if show_section && num_section_questions(self, section, phase) > 0
              show_section_for_csv(csv, phase, section, headings, unanswered, hash)
            end
          end
        end
      end
    end
  end

  private

  def prepare(coversheet = false)
    hash = coversheet ? prepare_coversheet : {}
    template = Template.includes(phases: { sections: { questions: :question_format } })
                       .joins(phases: { sections: { questions: :question_format } })
                       .where(id: self.template_id)
                       .order("sections.number", "questions.number").first
    hash[:customization] = template.customization_of.present?
    hash[:title] = self.title
    hash[:answers] = self.answers

    # add the relevant questions/answers
    phases = []
    template.phases.each do |phase|
      phs = { title: phase.title, number: phase.number, sections: [] }
      phase.sections.each do |section|
        sctn = { title: section.title,
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

  def prepare_coversheet_for_csv(csv, headings, hash)
    csv << [ hash[:attribution].many? ?
             _("Creators: ") :
             _("Creator:"), _("%{authors}") % { authors: hash[:attribution].join(", ") } ]
    csv << [ "Affiliation: ", _("%{affiliation}") % { affiliation: hash[:affiliation] } ]
    if hash[:funder].present?
      csv << [ _("Template: "), _("%{funder}") % { funder: hash[:funder] } ]
    else
      csv << [ _("Template: "), _("%{template}") % { template: hash[:template] + hash[:customizer] } ]
    end
    if self.grant_number.present?
      csv << [ _("Grant number: "), _("%{grant_number}") % { grant_number: self.grant_number } ]
    end
    if self.description.present?
      csv << [ _("Project abstract: "), _("%{description}") %
               { description: Nokogiri::HTML(self.description).text } ]
    end
    csv << [ _("Last modified: "), _("%{date}") % { date: self.updated_at.to_date.strftime("%d-%m-%Y") } ]
    csv << [ _("Copyright information:"),
             _("The above plan creator(s) have agreed that others may use as
             much of the text of this plan as they would like in their own plans,
             and customise it as necessary. You do not need to credit the creator(s)
             as the source of the language used, but using any of the plan's text
             does not imply that the creator(s) endorse, or have any relationship to,
             your project or proposal") ]
    csv << []
    csv << []
  end

  def show_section_for_csv(csv, phase, section, headings, unanswered, hash)
    section[:questions].each do |question|     
      if remove_list(hash).include?(question[:id]) 
        next
      end
      answer = self.answer(question[:id], false)
      answer_text = ""
      if answer.present?
        if answer.question_options.any?
          answer_text += answer.question_options.pluck(:text).join(", ")
        end
        if !answer.is_blank?
          answer_text += answer.text
        end
      elsif unanswered
        answer_text += _("Not Answered")
      end
      single_line_answer_for_csv = sanitize_text(answer_text).gsub(/\r|\n/, " ")
      flds = (hash[:phases].many? ? [phase[:title]] : [])
      if headings
        if question[:text].is_a? String
          question_text = question[:text]
        else
          question_text = (question[:text].many? ?
                           question[:text].join(", ") :
                           question[:text][0])
        end
        flds << [ section[:title], sanitize_text(question_text),
                  single_line_answer_for_csv ]
      else
        flds << [ single_line_answer_for_csv ]
      end
      csv << flds.flatten
    end
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
    ActionView::Base.full_sanitizer.sanitize(text.to_s.gsub(/&nbsp;/i, ""))
  end

end
