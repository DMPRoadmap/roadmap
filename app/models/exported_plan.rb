class ExportedPlan < ActiveRecord::Base
  include GlobalHelpers
  include SettingsTemplateHelper

# TODO: REMOVE AND HANDLE ATTRIBUTE SECURITY IN THE CONTROLLER!
  attr_accessible :plan_id, :user_id, :format, :user, :plan, :as => [:default, :admin]

  #associations between tables
  belongs_to :plan
  belongs_to :user

  VALID_FORMATS = ['csv', 'html', 'pdf', 'text', 'docx']

  validates :format, inclusion: {
    in: VALID_FORMATS,
    message: -> (object, data) do
      _('%{value} is not a valid format') % { :value => data[:value] }
    end
  }
  validates :plan, :format, presence: {message: _("can't be blank")}

  # Store settings with the exported plan so it can be recreated later
  # if necessary (otherwise the settings associated with the plan at a
  # given time can be lost)
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end

# TODO: Consider removing the accessor methods, they add no value. The view/controller could
#       just access the value directly from the project/plan: exported_plan.plan.project.title

  # Getters to match Settings::Template::VALID_ADMIN_FIELDS
  def project_name
    name = self.plan.template.title
    name += " - #{self.plan.title}" if self.plan.template.phases.count > 1
    name
  end

  def project_identifier
    self.plan.identifier
  end

  def grant_title
    self.plan.grant_number
  end

  def principal_investigator
    self.plan.principal_investigator
  end

  def project_data_contact
    self.plan.data_contact
  end

  def project_description
    self.plan.description
  end

  def owner
    self.plan.roles.to_a.select{ |role| role.creator? }.first.user
  end

  def funder
    org = self.plan.template.try(:org)
    org.name if org.present? && org.funder?
  end

  def institution
    plan.owner.org.try(:name)
  end

  def orcid
    scheme = IdentifierScheme.find_by(name: 'orcid')
    if self.owner.nil?
      ''
    else
      orcid = self.owner.user_identifiers.where(identifier_scheme: scheme).first
      (orcid.nil? ? '' : orcid.identifier)
    end
  end

  def sections
    self.phase_id ||= self.plan.template.phases.first.id
    Section.where({phase_id: phase_id}).order(:number)
  end

  def questions_for_section(section_id)
    Question.where(id: questions).where(section_id: section_id).order(:number)
  end

  def admin_details
    @admin_details ||= self.settings(:export).fields[:admin]
  end

  # Retrieves the title field
  def title
    self.settings(:export).title
  end

  # Export formats

  def as_csv(sections, unanswered_questions, question_headings)
    CSV.generate do |csv|
      if question_headings
        csv << [_('Section'),_('Question'),_('Answer'),_('Selected option(s)'),_('Answered by'),_('Answered at')]
      else
        csv << [_('Section'),_('Answer'),_('Selected option(s)'),_('Answered by'),_('Answered at')]
      end
      sections.each do |section|
        section.questions.each do |question|
          answer = Answer.where(plan_id: self.plan_id, question_id: question.id).first
          # skip unansewered questions
          if answer.blank? && !unanswered_questions
            next
          end
          answer_text = answer.present? ? answer.text : ''
          q_format = question.question_format
          if q_format.option_based?
            options_string = answer.question_options.collect {|o| o.text}.join('; ')
          else
            options_string = ''
          end
          if question_headings
            csv << [
              section.title,
              sanitize_text(question.text),
              question.option_comment_display ? sanitize_text(answer_text) : '',
              options_string,
              user.name,
              answer.updated_at
            ]
          else
            csv << [
              section.title,
              question.option_comment_display ? sanitize_text(answer_text) : '',
              options_string,
              user.name,
              answer.updated_at
            ]
          end
        end
      end
    end
  end

  def as_txt(sections, unanswered_questions, question_headings, details)
    output = "#{self.plan.title}\n\n#{self.plan.template.title}\n"
    output += "\n"+_('Details')+"\n\n"
    if details
      self.admin_details.each do |at|
          value = self.send(at)
          if value.present?
            output += admin_field_t(at.to_s) + ": " + value + "\n"
          else
            output += admin_field_t(at.to_s) + ": " + _('-') + "\n"
          end
      end
    end

    sections.each do |section|
      if question_headings
        output += "\n#{section.title}\n"
      end
      section.questions.each do |question|
        answer = self.plan.answer(question.id, false)
        #skip if question un-answered
        if answer.nil? && !unanswered_questions then next end

        if question_headings
          qtext = sanitize_text( question.text.gsub(/<li>/, '  * ') )
          output += "\n* #{qtext}"
        end
        if answer.nil?
          output += _('Question not answered.')+ "\n"
        else
          q_format = question.question_format
          if q_format.option_based?
            output += answer.question_options.collect {|o| o.text}.join("\n")
            if question.option_comment_display
              output += "\n#{sanitize_text(answer.text)}\n"
            end
          else
            output += "\n#{sanitize_text(answer.text)}\n"
          end
        end
      end
    end
    output
  end

private
  # Returns an Array of question_ids for the exported settings stored for a plan
  def questions
    question_settings = self.settings(:export).fields[:questions]
    @questions ||= if question_settings.present?
      if question_settings == :all
        Question.where(section_id: self.plan.sections.collect { |s| s.id }).pluck(:id)
      elsif question_settings.is_a?(Array)
        question_settings
      else
        []
      end
    else
      []
    end
  end

  def sanitize_text(text)
    if (!text.nil?) then ActionView::Base.full_sanitizer.sanitize(text.gsub(/&nbsp;/i,"")) end
  end

end
