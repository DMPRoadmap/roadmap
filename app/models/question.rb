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
#
# Indexes
#
#  index_questions_on_section_id  (section_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_format_id => question_formats.id)
#  fk_rails_...  (section_id => sections.id)
#

class Question < ActiveRecord::Base
  include ValidationMessages
  include ActsAsSortable

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

  validates :text, presence: { message: PRESENCE_MESSAGE }

  validates :section, presence: { message: PRESENCE_MESSAGE }

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

  accepts_nested_attributes_for :annotations, allow_destroy: true


  # ===========================
  # = Public instance methods =
  # ===========================

  ##
  # returns the text from the question
  #
  # @return [String] question's text
  def to_s
    "#{text}"
  end

  def option_based?
    format = self.question_format
    return format.option_based
  end

  def deep_copy(**options)
    copy = self.dup
    copy.modifiable = options.fetch(:modifiable, self.modifiable)
    copy.section_id = options.fetch(:section_id, nil)
    copy.save!(validate: false)  if options.fetch(:save, false)
    options[:question_id] = copy.id
    self.question_options.each{ |question_option| copy.question_options << question_option.deep_copy(options) }
    self.annotations.each{ |annotation| copy.annotations << annotation.deep_copy(options) }
    self.themes.each{ |theme| copy.themes << theme }
    return copy
  end

# TODO: consider moving this to a view helper instead and use the built in scopes for guidance. May need to add
#       a new one for 'thematic_guidance'. This method doesn't even make reference to this class and its returning
#       a hash that is specific to a view
  ##
  # guidance for org
  #
  # @param org [Org] the org to find guidance for
  # @return [Hash{String => String}]
  def guidance_for_org(org)
    # pulls together guidance from various sources for question
    guidances = {}
    theme_ids = themes.collect{|t| t.id}
    if theme_ids.present?
      GuidanceGroup.includes(guidances: :themes).where(org_id: org.id).each do |group|
        group.guidances.each do |g|
          g.themes.each do |theme|
            if theme_ids.include? theme.id
              guidances["#{group.name} " + _('guidance on') + " #{theme.title}"] = g
            end
          end
        end
      end
    end

    return guidances
   end

  ##
  # get example answer belonging to the currents user for this question
  #
  # @param org_ids [Array<Integer>] the ids for the organisations
  # @return [Array<Annotation>] the example answers for this question for the specified orgs
   def get_example_answers(org_ids)
    org_ids = [org_ids] unless org_ids.is_a?(Array)
    self.annotations.where(org_id: org_ids, type: Annotation.types[:example_answer]).order(:created_at)
   end

  ##
  # get guidance belonging to the current user's org for this question(need org
  # to distinguish customizations)
  #
  # @param org_id [Integer] the id for the organisation
  # @return [String] the annotation guidance for this question for the specified org
  def get_guidance_annotation(org_id)
    guidance = self.annotations.where(org_id: org_id).where(type: Annotation.types[:guidance])
    return guidance.first
  end

  def annotations_per_org(org_id)
    example_answer = annotations.find_by(org_id: org_id, type: Annotation.types[:example_answer])
    guidance = annotations.find_by(org_id: org_id, type: Annotation.types[:guidance])
    example_answer = annotations.build({ type: :example_answer, text: '', org_id: org_id }) unless example_answer.present?
    guidance = annotations.build({ type: :guidance, text: '', org_id: org_id }) unless guidance.present?
    return [example_answer, guidance]
  end
end
