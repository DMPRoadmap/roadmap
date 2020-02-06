# frozen_string_literal: true

# == Schema Information
#
# Table name: sections
#
#  id             :integer          not null, primary key
#  description    :text
#  modifiable     :boolean
#  number         :integer
#  title          :string
#  created_at     :datetime
#  updated_at     :datetime
#  phase_id       :integer
#  versionable_id :string(36)
#
# Indexes
#
#  index_sections_on_phase_id        (phase_id)
#  index_sections_on_versionable_id  (versionable_id)
#
# Foreign Keys
#
#  fk_rails_...  (phase_id => phases.id)
#

class Section < ActiveRecord::Base

  include ValidationMessages
  include ValidationValues
  include ActsAsSortable
  include VersionableModel

  # Sort order: Number ASC
  default_scope { order(number: :asc) }

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

  validates :modifiable, inclusion: { in: BOOLEAN_VALUES,
                                      message: INCLUSION_MESSAGE }

  # =============
  # = Callbacks =
  # =============

  # TODO: Move this down to DB constraints
  before_validation :set_modifiable

  before_validation :set_number, if: :phase_id_changed?

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
  # Returns ActiveRecord::Relation
  scope :modifiable, -> { where(modifiable: true) }

  # The sections for this Phase that were part of the original Template
  #
  # Returns ActiveRecord::Relation
  scope :not_modifiable, -> { where(modifiable: false) }

  # ===========================
  # = Public instance methods =
  # ===========================

  # The title of the Section
  #
  # Returns String
  def to_s
    "#{title}"
  end

  # Returns the number of answered questions for a given plan
  def num_answered_questions(plan)
    self.answered_questions(plan).count(&:answered?)
  end

  # Returns an array of answered questions for a given plan
  def answered_questions(plan)
    return [] if plan.nil?
    plan.answers.includes({ question: :question_format }, :question_options)
                .where(question_id: question_ids)
                .to_a
  end

  def deep_copy(**options)
    copy = self.dup
    copy.modifiable = options.fetch(:modifiable, self.modifiable)
    copy.phase_id = options.fetch(:phase_id, nil)
    copy.save!(validate: false)  if options.fetch(:save, false)
    options[:section_id] = copy.id
    self.questions.map { |question| copy.questions << question.deep_copy(options) }
    copy
  end

  # Can't be modified as it was duplicatd over from another Phase.
  def unmodifiable?
    !modifiable?
  end

  private

  # ============================
  # = Private instance methods =
  # ============================

  def set_modifiable
    self.modifiable = true if modifiable.nil?
  end

  def set_number
    return if phase.nil?
    self.number = phase.sections.where.not(id: id).maximum(:number).to_i + 1
  end

end
