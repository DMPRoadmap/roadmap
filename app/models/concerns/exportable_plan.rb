# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module ExportablePlan

  include ConditionsHelper

  def as_pdf(coversheet = false)
    prepare(coversheet)
  end

  # rubocop:disable Metrics/AbcSize
  def as_csv(headings = true,
             unanswered = true,
             selected_phase = nil,
             show_custom_sections = true,
             show_coversheet = false)
    hash = prepare(show_coversheet)
    CSV.generate do |csv|
      prepare_coversheet_for_csv(csv, headings, hash) if show_coversheet

      hdrs = (hash[:phases].many? ? [_("Phase")] : [])
      hdrs << if headings
                [_("Section"), _("Question"), _("Answer")]
              else
                [_("Answer")]
              end

      customization = hash[:customization]

      csv << hdrs.flatten
      hash[:phases].each do |phase|
        next unless selected_phase.nil? || phase[:title] == selected_phase.title

        phase[:sections].each do |section|
          show_section = !customization
          show_section ||= customization && !section[:modifiable]
          show_section ||= customization && section[:modifiable] && show_custom_sections

          if show_section && num_section_questions(self, section, phase).positive?
            show_section_for_csv(csv, phase, section, headings, unanswered, hash)
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def prepare(coversheet = false)
    hash = coversheet ? prepare_coversheet : {}
    template = Template.includes(phases: { sections: { questions: :question_format } })
                       .joins(phases: { sections: { questions: :question_format } })
                       .where(id: template_id)
                       .order("sections.number", "questions.number").first
    hash[:customization] = template.customization_of.present?
    hash[:title] = title
    hash[:answers] = answers

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
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def prepare_coversheet
    hash = {}
    # name of owner and any co-owners
    attribution = owner.present? ? [owner.name(false)] : []
    roles.administrator.not_creator.each do |role|
      attribution << role.user.name(false)
    end
    hash[:attribution] = attribution

    # Org name of plan owner's org
    hash[:affiliation] = owner.present? ? owner.org.name : ""

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
  # rubocop:enable

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def prepare_coversheet_for_csv(csv, _headings, hash)
    csv << [if hash[:attribution].many?
              _("Creators: ")
            else
              _("Creator:")
            end, _("%{authors}") % { authors: hash[:attribution].join(", ") }]
    csv << ["Affiliation: ", _("%{affiliation}") % { affiliation: hash[:affiliation] }]
    csv << if hash[:funder].present?
             [_("Template: "), _("%{funder}") % { funder: hash[:funder] }]
           else
             [_("Template: "), _("%{template}") % { template: hash[:template] + hash[:customizer] }]
           end
    if grant_number.present?
      csv << [_("Grant number: "), _("%{grant_number}") % { grant_number: grant_number }]
    end
    if description.present?
      csv << [_("Project abstract: "), _("%{description}") %
                                       { description: Nokogiri::HTML(description).text }]
    end
    csv << [_("Last modified: "), _("%{date}") % { date: updated_at.to_date.strftime("%d-%m-%Y") }]
    csv << [_("Copyright information:"),
            _("The above plan creator(s) have agreed that others may use as
             much of the text of this plan as they would like in their own plans,
             and customise it as necessary. You do not need to credit the creator(s)
             as the source of the language used, but using any of the plan's text
             does not imply that the creator(s) endorse, or have any relationship to,
             your project or proposal")]
    csv << []
    csv << []
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/BlockLength, Metrics/MethodLength
  # rubocop:disable Metrics/ParameterLists
  def show_section_for_csv(csv, phase, section, headings, unanswered, hash)
    section[:questions].each do |question|
      next if remove_list(hash).include?(question[:id])

      answer = self.answer(question[:id], false)
      answer_text = ""
      if answer.present?
        if answer.question_options.any?
          answer_text += answer.question_options.pluck(:text).join(", ")
        end
        answer_text += answer.text if answer.answered?
      elsif unanswered
        answer_text += _("Not Answered")
      end
      single_line_answer_for_csv = sanitize_text(answer_text).gsub(/\r|\n/, " ")
      flds = (hash[:phases].many? ? [phase[:title]] : [])
      if headings
        question_text = if question[:text].is_a? String
                          question[:text]
                        else
                          (if question[:text].many?
                             question[:text].join(", ")
                           else
                             question[:text][0]
                           end)
                        end
        flds << [section[:title], sanitize_text(question_text),
                 single_line_answer_for_csv]
      else
        flds << [single_line_answer_for_csv]
      end
      csv << flds.flatten
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/BlockLength, Metrics/MethodLength
  # rubocop:enable
  # rubocop:enable Metrics/ParameterLists

  def record_plan_export(format)
    exported_plan = ExportedPlan.new.tap do |ep|
      ep.plan = self
      ep.phase_id = phases.first.id
      ep.format = format
      plan_settings = settings(:export)

      Settings::Template::DEFAULT_SETTINGS.each do |key, _value|
        ep.settings(:export).send("#{key}=", plan_settings.send(key))
      end
    end
    exported_plan.save
  end

  def sanitize_text(text)
    ActionView::Base.full_sanitizer.sanitize(text.to_s.gsub(/&nbsp;/i, ""))
  end

end
# rubocop:enable Metrics/ModuleLength
