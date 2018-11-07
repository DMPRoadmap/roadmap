# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id                     :integer          not null, primary key
#  default_value          :text
#  modifiable             :boolean
#  number                 :integer
#  option_comment_display :boolean          default(TRUE)
#  text                   :text
#  created_at             :datetime
#  updated_at             :datetime
#  question_format_id     :integer
#  section_id             :integer
#  versionable_id         :string(36)
#
# Indexes
#
#  index_questions_on_section_id      (section_id)
#  index_questions_on_versionable_id  (versionable_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_format_id => question_formats.id)
#  fk_rails_...  (section_id => sections.id)
#

class Question < ActiveRecord::Base

  include ValidationMessages
  include ActsAsSortable
  include VersionableModel

  # ==============
  # = Attributes =
  # ==============

  alias_attribute :to_s, :text

  # include
  ##
  # Sort order: Number ASC
  default_scope { order(number: :asc) }

  # ================
  # = Associations =
  # ================

  has_many :answers, dependent: :destroy

  # inverse_of needed for nested forms
  has_many :question_options, dependent: :destroy, inverse_of: :question

  has_many :annotations, dependent: :destroy, inverse_of: :question

  has_and_belongs_to_many :themes, join_table: "questions_themes"

  belongs_to :section

  belongs_to :question_format

  has_one :phase, through: :section

  has_one :template, through: :section

  # ===============
  # = Validations =
  # ===============

  validate :ensure_has_question_options, if: :option_based?

  validates :text, presence: { message: PRESENCE_MESSAGE }

  validates :section, presence: { message: PRESENCE_MESSAGE, on: :update }

  validates :question_format, presence: { message: PRESENCE_MESSAGE }

  validates :number, presence: { message: PRESENCE_MESSAGE },
                     uniqueness: { scope: :section_id,
                                   message: UNIQUENESS_MESSAGE }


  # =====================
  # = Nested Attributes =
  # =====================

  # TODO: evaluate if we need this
  accepts_nested_attributes_for :answers, reject_if: -> (a) { a[:text].blank? },
                                  allow_destroy: true

  accepts_nested_attributes_for :question_options, allow_destroy: true,
                                  reject_if: -> (a) { a[:text].blank? }

  accepts_nested_attributes_for :annotations, allow_destroy: true,
                                  reject_if: proc { |a| a[:text].blank? && a[:id].blank? }

  # =====================
  # = Delegated methods =
  # =====================

  delegate :option_based?, to: :question_format, :allow_nil => true

  # ===========================
  # = Public instance methods =
  # ===========================

  def deep_copy(**options)
    copy = self.dup
    copy.modifiable = options.fetch(:modifiable, self.modifiable)
    copy.section_id = options.fetch(:section_id, nil)
    copy.save!(validate: false)  if options.fetch(:save, false)
    options[:question_id] = copy.id
    self.question_options.each do |question_option|
      copy.question_options << question_option.deep_copy(options)
    end
    self.annotations.each do |annotation|
      copy.annotations << annotation.deep_copy(options)
    end
    self.themes.each { |theme| copy.themes << theme }
    copy
  end

  # TODO: consider moving this to a view helper instead and use the built in
  # scopes for guidance. May need to add a new one for 'thematic_guidance'.
  # This method doesn't even make reference to this class and its returning
  # a hash that is specific to a view guidance for org
  #
  # org - The Org to find guidance for
  #
  # Returns Hash
  def guidance_for_org(org)
    # pulls together guidance from various sources for question
    guidances = {}
    if theme_ids.any?
      GuidanceGroup.includes(guidances: :themes)
                   .where(org_id: org.id).each do |group|
        group.guidances.each do |g|
          g.themes.each do |theme|
            if theme_ids.include? theme.id
              guidances["#{group.name} " + _("guidance on") + " #{theme.title}"] = g
            end
          end
        end
      end
    end

    guidances
  end

  # get example answer belonging to the currents user for this question
  #
  # org_ids - The ids for the organisations
  #
  # Returns ActiveRecord::Relation
  def example_answers(org_ids)
    annotations.where(org_id: Array(org_ids),
                      type: Annotation.types[:example_answer])
               .order(:created_at)
  end

  alias get_example_answers example_answers

  deprecate :get_example_answers,
              deprecator: Cleanup::Deprecators::GetDeprecator.new

  # get guidance belonging to the current user's org for this question(need org
  # to distinguish customizations)
  #
  # org_id - The id for the organisation
  #
  # Returns Annotation
  def guidance_annotation(org_id)
    annotations.where(org_id: org_id, type: Annotation.types[:guidance]).first
  end

  alias get_guidance_annotation guidance_annotation

  deprecate :get_guidance_annotation,
              deprecator: Cleanup::Deprecators::GetDeprecator.new

  def annotations_per_org(org_id)
    example_answer = annotations.find_by(org_id: org_id,
                                         type: Annotation.types[:example_answer])
    guidance = annotations.find_by(org_id: org_id,
                                   type: Annotation.types[:guidance])
    unless example_answer.present?
      example_answer = annotations.build(type: :example_answer, text: "", org_id: org_id)
    end
    unless guidance.present?
      guidance = annotations.build(type: :guidance, text: "", org_id: org_id)
    end
    [example_answer, guidance]
  end

  private

  def ensure_has_question_options
    if question_options.empty?
      errors.add :base, OPTION_PRESENCE_MESSAGE
    end
  end

end
