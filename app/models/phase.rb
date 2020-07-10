# frozen_string_literal: true

# == Schema Information
#
# Table name: phases
#
#  id             :integer          not null, primary key
#  description    :text
#  modifiable     :boolean
#  number         :integer
#  title          :string
#  created_at     :datetime
#  updated_at     :datetime
#  template_id    :integer
#  versionable_id :string(36)
#
# Indexes
#
#  index_phases_on_template_id     (template_id)
#  index_phases_on_versionable_id  (versionable_id)
#
# Foreign Keys
#
#  fk_rails_...  (template_id => templates.id)
#

# [+Project:+] DMPRoadmap
# [+Description:+] This model describes informmation about the phase of a plan,
#                  it's title, order of display and which template it belongs to.
#
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center
class Phase < ApplicationRecord

  include ActsAsSortable
  include VersionableModel
  include ConditionsHelper

  ##
  # Sort order: Number ASC
  default_scope { order(number: :asc) }

  # ================
  # = Associations =
  # ================
  belongs_to :template, touch: true

  belongs_to :plan, optional: true

  has_one :prefix_section, lambda { |phase|
    modifiable.where("number < ?",
                     phase.sections.not_modifiable.minimum(:number))
  }, class_name: "Section"

  has_many :sections, dependent: :destroy

  has_many :questions, through: :sections

  has_many :answers, through: :questions

  has_many :annotations, through: :questions

  has_many :template_sections, lambda {
    not_modifiable
  }, class_name: "Section"

  has_many :suffix_sections, lambda { |phase|
    modifiable.where(<<~SQL, phase_id: phase.id, modifiable: false)
      sections.number > (SELECT MAX(number) FROM sections
                           WHERE sections.modifiable = :modifiable
                           AND sections.phase_id = :phase_id)
    SQL
  }, class_name: "Section"

  # ===============
  # = Validations =
  # ===============

  validates :title, presence: { message: PRESENCE_MESSAGE }

  validates :number, presence: { message: PRESENCE_MESSAGE },
                     uniqueness: { message: UNIQUENESS_MESSAGE,
                                   scope: :template_id }

  validates :template, presence: { message: PRESENCE_MESSAGE }

  validates :modifiable, inclusion: { in: BOOLEAN_VALUES,
                                      message: INCLUSION_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  scope :titles, lambda { |template_id|
    Phase.where(template_id: template_id).select(:id, :title)
  }

  def deep_copy(**options)
    copy = dup
    copy.modifiable = options.fetch(:modifiable, modifiable)
    copy.template_id = options.fetch(:template_id, nil)
    copy.save!(validate: false) if options.fetch(:save, false)
    options[:phase_id] = copy.id
    sections.each { |section| copy.sections << section.deep_copy(options) }
    copy
  end

  # TODO: Move this to Plan model as `num_answered_questions(phase=nil)`
  # Returns the number of answered question for the phase.
  def num_answered_questions(plan)
    plan&.num_answered_questions.to_i
  end

  # Returns the number of questions for a phase. Note, this method becomes useful
  # for when sections and their questions are eager loaded so that avoids SQL queries.
  def num_questions
    n = 0
    sections.each do |s|
      n += s.questions.size
    end
    n
  end

  def num_questions_not_removed(plan)
    count = 0
    sections.each do |section|
      count += num_section_questions(plan, section)
    end
    count
  end

  def num_answers_not_removed(plan)
    count = 0
    sections.each do |section|
      count += num_section_answers(plan, section)
    end
    count
  end

  def visibility_allowed?(plan)
    value = Rational(num_answered_questions(plan), plan.num_questions) * 100
    value >= Rails.configuration.x.plans.default_percentage_answered.to_f
  end

end
