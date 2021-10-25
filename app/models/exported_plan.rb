# frozen_string_literal: true

# == Schema Information
#
# Table name: exported_plans
#
#  id         :integer          not null, primary key
#  format     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  phase_id   :integer
#  plan_id    :integer
#  user_id    :integer
#
class ExportedPlan < ApplicationRecord

  include SettingsTemplateHelper

  # associations between tables
  belongs_to :plan
  belongs_to :user, optional: true

  validates :plan, presence: { message: PRESENCE_MESSAGE }

  validates :format, presence: { message: PRESENCE_MESSAGE }

  # Store settings with the exported plan so it can be recreated later
  # if necessary (otherwise the settings associated with the plan at a
  # given time can be lost)
  has_settings :export, class_name: "Settings::Template" do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end

  # TODO: Consider removing the accessor methods, they add no value. The view/controller could
  #       just access the value directly from the project/plan: exported_plan.plan.project.title

  # Getters to match Settings::Template::VALID_ADMIN_FIELDS
  def project_name
    name = plan.template.title
    name += " - #{plan.title}" if plan.template.phases.count > 1
    name
  end

  def project_identifier
    plan.identifier
  end

  def grant_title
    plan.grant&.value
  end

  def principal_investigator
    plan.contributors.investigation
  end

  def project_data_contact
    plan.contributors.data_curation
  end

  def project_admins
    plan.contributors.project_administration
  end

  def project_description
    plan.description
  end

  def owner
    plan.roles.to_a.select(&:creator?).first.user
  end

  def funder
    org = plan.funder
    org = plan.template.try(:org) unless org.present?
    org.name if org.present? && org.funder?
  end

  def institution
    plan.owner.org.try(:name)
  end

  def orcid
    return "" unless owner.present?

    ids = owner.identifiers.by_scheme_name("orcid", "User")
    ids.first.present? ? ids.first.value : ""
  end

  def sections
    self.phase_id ||= plan.template.phases.first.id
    Section.where({ phase_id: phase_id }).order(:number)
  end

  def questions_for_section(section_id)
    Question.where(id: questions).where(section_id: section_id).order(:number)
  end

  def admin_details
    @admin_details ||= settings(:export).fields[:admin]
  end

  # Retrieves the title field
  def title
    settings(:export).title
  end

  # Export formats

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength
  def as_csv(sections, unanswered_questions, question_headings)
    CSV.generate do |csv|
      # rubocop:disable Style/ConditionalAssignment
      if question_headings
        csv << [_("Section"), _("Question"), _("Answer"), _("Selected option(s)"),
                _("Answered by"), _("Answered at")]
      else
        csv << [_("Section"), _("Answer"), _("Selected option(s)"), _("Answered by"),
                _("Answered at")]
      end
      # rubocop:enable Style/ConditionalAssignment
      sections.each do |section|
        section.questions.each do |question|
          answer = Answer.where(plan_id: plan_id, question_id: question.id).first
          # skip unansewered questions
          next if answer.blank? && !unanswered_questions

          answer_text = answer.present? ? answer.text : ""
          q_format = question.question_format
          options_string = if q_format.option_based?
                             answer.question_options.collect(&:text).join("; ")
                           else
                             ""
                           end
          csv << if question_headings
                   [
                     section.title,
                     sanitize_text(question.text),
                     question.option_comment_display ? sanitize_text(answer_text) : "",
                     options_string,
                     user.name,
                     answer.updated_at
                   ]
                 else
                   [
                     section.title,
                     question.option_comment_display ? sanitize_text(answer_text) : "",
                     options_string,
                     user.name,
                     answer.updated_at
                   ]
                 end
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength
  # rubocop:enable

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def as_txt(sections, unanswered_questions, question_headings, details)
    output = "#{plan.title}\n\n#{plan.template.title}\n"
    output += "\n" + _("Details") + "\n\n"
    if details
      admin_details.each do |at|
        value = send(at)
        output += if value.present?
                    admin_field_t(at.to_s) + ": " + value + "\n"
                  else
                    admin_field_t(at.to_s) + ": " + _("-") + "\n"
                  end
      end
    end

    sections.each do |section|
      output += "\n#{section.title}\n" if question_headings
      section.questions.each do |question|
        answer = plan.answer(question.id, false)
        # skip if question un-answered
        next if answer.nil? && !unanswered_questions

        if question_headings
          qtext = sanitize_text(question.text.gsub(/<li>/, "  * "))
          output += "\n* #{qtext}"
        end
        if answer.nil?
          output += _("Question not answered.") + "\n"
        else
          q_format = question.question_format
          if q_format.option_based?
            output += answer.question_options.collect(&:text).join("\n")
            output += "\n#{sanitize_text(answer.text)}\n" if question.option_comment_display
          else
            output += "\n#{sanitize_text(answer.text)}\n"
          end
        end
      end
    end
    output
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable

  private

  # Returns an Array of question_ids for the exported settings stored for a plan
  def questions
    question_settings = settings(:export).fields[:questions]
    @questions ||= if question_settings.present?
                     if question_settings == :all
                       Question.where(section_id: plan.sections.collect(&:id)).pluck(:id)
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
    ActionView::Base.full_sanitizer.sanitize(text.gsub(/&nbsp;/i, "")) unless text.nil?
  end

end
