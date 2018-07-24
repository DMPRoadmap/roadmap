# == Schema Information
#
# Table name: sections
#
#  id          :integer          not null, primary key
#  description :text
#  modifiable  :boolean
#  number      :integer
#  published   :boolean
#  title       :string
#  created_at  :datetime
#  updated_at  :datetime
#  phase_id    :integer
#
# Indexes
#
#  index_sections_on_phase_id  (phase_id)
#
# Foreign Keys
#
#  fk_rails_...  (phase_id => phases.id)
#

class Section < ActiveRecord::Base
  include ValidationMessages
  include ValidationValues
  include ActsAsSortable

  # ================
  # = Associations =
  # ================

  belongs_to :phase
  belongs_to :organisation
  has_many :questions, dependent: :destroy
  has_one :template, through: :phase

  # ===============
  # = Validations =
  # ===============

  validates :phase, presence: { message: PRESENCE_MESSAGE }

  validates :title, presence: { message: PRESENCE_MESSAGE }

  # validates :description, presence: { message: PRESENCE_MESSAGE }

  validates :number, presence: { message: PRESENCE_MESSAGE },
                     uniqueness: { scope: :phase_id,
                                   message: UNIQUENESS_MESSAGE }

  validates :published, inclusion: { in: BOOLEAN_VALUES,
                                      message: INCLUSION_MESSAGE }

  validates :modifiable, inclusion: { in: BOOLEAN_VALUES,
                                      message: INCLUSION_MESSAGE }

  # =============
  # = Callbacks =
  # =============

  # TODO: Move this down to DB constraints
  before_validation :set_defaults

  # =====================
  # = Nested Attributes =
  # =====================

  accepts_nested_attributes_for :questions,
    reject_if: -> (a) { a[:text].blank? },
    allow_destroy: true

  # ==========
  # = Scopes =
  # ==========

  # The sections for this Phase that have been added by the admin
  #
  # @!scope class
  # @return [ActiveRecord::Relation] Returns the sections that are modifiable
  scope :modifiable, -> { where(modifiable: true) }

  # The sections for this Phase that were part of the original Template
  #
  # @!scope class
  # @return [ActiveRecord::Relation] Returns the sections that aren't modifiable
  scope :not_modifiable, -> { where(modifiable: false) }

  # ===========================
  # = Public instance methods =
  # ===========================

  ##
  # return the title of the section
  #
  # @return [String] the title of the section
  def to_s
    "#{title}"
  end

  # Returns the number of answered questions for a given plan
  def num_answered_questions(plan)
    return 0 if plan.nil?
    plan.answers.includes({ question: :question_format }, :question_options)
                .where(question_id: question_ids)
                .to_a
                .count(&:is_valid?)
  end

  def deep_copy(**options)
    copy = self.dup
    copy.modifiable = options.fetch(:modifiable, self.modifiable)
    copy.phase_id = options.fetch(:phase_id, nil)
    copy.save!(validate: false)  if options.fetch(:save, false)
    options[:section_id] = copy.id
    self.questions.map{ |question| copy.questions << question.deep_copy(options) }
    return copy
  end

  private

  # ============================
  # = Private instance methods =
  # ============================

  def set_defaults
    self.modifiable = true if modifiable.nil?
  end
end
