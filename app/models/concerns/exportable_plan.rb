# frozen_string_literal: true

# TODO: This code here doesn't make a lot of sense as a Concern since no other model would
#       ever use the functionality. It would be better to make it a Service.

# Module that provides helper methods for exporting a Plan in various formats
# rubocop:disable Metrics/ModuleLength
module ExportablePlan
  include ConditionsHelper

  # rubocop:disable Style/OptionalBooleanParameter
  def as_pdf(user, coversheet = false)
    prepare(user, coversheet)
  end
  # rubocop:enable Style/OptionalBooleanParameter

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/ParameterLists
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:disable Style/OptionalBooleanParameter
  def as_csv(user,
             headings = true,
             unanswered = true,
             selected_phase = nil,
             show_custom_sections = true,
             show_coversheet = false)
    hash = prepare(user, show_coversheet)
    CSV.generate do |csv|
      prepare_coversheet_for_csv(csv, headings, hash) if show_coversheet

      hdrs = (hash[:phases].many? ? [_('Phase')] : [])
      hdrs << if headings
                [_('Section'), _('Question'), _('Answer')]
              else
                [_('Answer')]
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
  # rubocop:enable Style/OptionalBooleanParameter
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/ParameterLists
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Style/OptionalBooleanParameter
  def prepare(user, coversheet = false)
    hash = coversheet ? prepare_coversheet : {}
    template = Template.includes(phases: { sections: { questions: :question_format } })
                       .joins(phases: { sections: { questions: :question_format } })
                       .where(id: template_id)
                       .order('sections.number', 'questions.number').first
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

    record_plan_export(user, :pdf)

    hash
  end

  # rubocop:enable Style/OptionalBooleanParameter

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def prepare_coversheet
    hash = {}
    # Use the name of the DMP owner/creator OR the first Co-owner if there is no
    # owner for some reason
    attribution = roles.creator.first&.user&.name(false)
    roles.administrator.not_creator.first&.user&.name(false) unless attribution.present?
    hash[:attribution] = attribution

    # Added contributors to coverage of plans.
    # Users will see both roles and contributor names if the role is filled
    hash[:data_curation] = Contributor.where(plan_id: id).data_curation
    hash[:investigation] = Contributor.where(plan_id: id).investigation
    hash[:pa] = Contributor.where(plan_id: id).project_administration
    hash[:other] = Contributor.where(plan_id: id).other

    # Org name of plan owner's org
    hash[:affiliation] = owner.present? ? owner.org.name : ''

    # set the funder name
    hash[:funder] = funder.name if funder.present?
    template_org = template.org
    hash[:funder] = template_org.name if !hash[:funder].present? && template_org.funder?

    # set the template name and customizer name if applicable
    hash[:template] = template.title
    customizer = ''
    cust_questions = questions.where(modifiable: true).pluck(:id)
    # if the template is customized, and has custom answered questions
    if template.customization_of.present? &&
       Answer.where(plan_id: id, question_id: cust_questions).present?
      customizer = _(' Customised By: ') + template.org.name
    end
    hash[:customizer] = customizer
    hash
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def prepare_coversheet_for_csv(csv, _headings, hash)
    csv << [_('Title: '), format(_('%{title}'), title: title)]
    csv << if Array(hash[:attribution]).many?
             [_('Creators: '), format(_('%{authors}'), authors: Array(hash[:attribution]).join(', '))]
           else
             [_('Creator:'), format(_('%{authors}'), authors: hash[:attribution])]
           end
    if hash[:investigation].present?
      csv << [_('Principal Investigator: '),
              format(_('%{investigation}'), investigation: hash[:investigation].map(&:name).join(', '))]
    end
    if hash[:data_curation].present?
      csv << [_('Date Manager: '),
              format(_('%{data_curation}'), data_curation: hash[:data_curation].map(&:name).join(', '))]
    end
    if hash[:pa].present?
      csv << [_('Project Administrator: '), format(_('%{pa}'), pa: hash[:pa].map(&:name).join(', '))]
    end
    if hash[:other].present?
      csv << [_('Contributor: '), format(_('%{other}'), other: hash[:other].map(&:name).join(', '))]
    end
    csv << [_('Affiliation: '), format(_('%{affiliation}'), affiliation: hash[:affiliation])]
    csv << ['Affiliation: ', format(_('%{affiliation}'), affiliation: hash[:affiliation])]
    csv << if hash[:funder].present?
             [_('Template: '), format(_('%{funder}'), funder: hash[:funder])]
           else
             [_('Template: '), format(_('%{template}'), template: hash[:template] + hash[:customizer])]
           end
    csv << [_('Grant number: '), format(_('%{grant_number}'), grant_number: grant&.value)] if grant&.value.present?
    if description.present?
      csv << [_('Project abstract: '), format(_('%{description}'), description: Nokogiri::HTML(description).text)]
    end
    csv << [_('Last modified: '), format(_('%{date}'), date: updated_at.to_date.strftime('%d-%m-%Y'))]
    csv << [_('Copyright information:'),
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
      answer_text = ''
      if answer.present?
        answer_text += answer.question_options.pluck(:text).join(', ') if answer.question_options.any?
        answer_text += answer.text if answer.answered? && answer.text.present?
      elsif unanswered
        answer_text += _('Not Answered')
      end
      single_line_answer_for_csv = sanitize_text(answer_text).gsub(/\r|\n/, ' ')
      flds = (hash[:phases].many? ? [phase[:title]] : [])
      if headings
        question_text = if question[:text].is_a? String
                          question[:text]
                        else
                          (if question[:text].many?
                             question[:text].join(', ')
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
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/ParameterLists

  # rubocop:disable Metrics/AbcSize
  def record_plan_export(user, format)
    # TODO: Re-evaluate how/why we are doing this. The only place it is used is in statistics
    #       generation as 'downloads' without any regard for the format (although we only call this
    #       here when a PDF is generated). It would be more efficient to probably just have a
    #       counter on the plans table itself. (e.g. plans.nbr_downloads)
    #       This would require a fair bit of work though, as the column would need to be added,
    #       the ExportedPlan model/table removed, statistics generation Rake task updated
    exported_plan = ExportedPlan.new.tap do |ep|
      ep.user_id = user&.id
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
  # rubocop:enable Metrics/AbcSize

  def sanitize_text(text)
    ActionView::Base.full_sanitizer.sanitize(text.to_s.gsub(/&nbsp;/i, ''))
  end
end
# rubocop:enable Metrics/ModuleLength
