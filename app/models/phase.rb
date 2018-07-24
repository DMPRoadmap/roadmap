# == Schema Information
#
# Table name: phases
#
#  id          :integer          not null, primary key
#  description :text
#  modifiable  :boolean
#  number      :integer
#  slug        :string
#  title       :string
#  created_at  :datetime
#  updated_at  :datetime
#  template_id :integer
#
# Indexes
#
#  index_phases_on_template_id  (template_id)
#
# Foreign Keys
#
#  fk_rails_...  (template_id => templates.id)
#

# [+Project:+] DMPRoadmap
# [+Description:+] This model describes informmation about the phase of a plan, it's title, order of display and which template it belongs to.
#
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center
class Phase < ActiveRecord::Base
  include ValidationMessages
  include ValidationValues
  include ActsAsSortable

  ##
  # Sort order: Number ASC
  default_scope { order(number: :asc) }

  # ================
  # = Associations =
  # ================
  belongs_to :template

  has_one :prefix_section, -> (phase) {
    modifiable.where("number < ?",
                      phase.sections.not_modifiable.minimum(:number))
  }, class_name: "Section"

  has_many :sections, dependent: :destroy

  has_many :template_sections, -> {
    not_modifiable
  }, class_name: "Section"


  has_many :suffix_sections, -> (phase) {
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

  scope :titles, -> (template_id) {
    Phase.where(template_id: template_id).select(:id, :title)
  }

  # TODO: Remove after implementing new template versioning logic
  # Callbacks
  after_save do |phase|
    # Updates the template.updated_at attribute whenever a phase has been created/updated
    phase.template.touch if template.present?
  end

  def deep_copy(**options)
    copy = self.dup
    copy.modifiable = options.fetch(:modifiable, self.modifiable)
    copy.template_id = options.fetch(:template_id, nil)
    copy.save!(validate:false)  if options.fetch(:save, false)
    options[:phase_id] = copy.id
    self.sections.each{ |section| copy.sections << section.deep_copy(options) }
    return copy
  end

  # TODO: Move this to Plan model as `num_answered_questions(phase=nil)`
  # Returns the number of answered question for the phase.
  def num_answered_questions(plan)
    return 0 if plan.nil?
    return sections.reduce(0) do |m, s|
      m + s.num_answered_questions(plan)
    end
  end

  # Returns the number of questions for a phase. Note, this method becomes useful
  # for when sections and their questions are eager loaded so that avoids SQL queries.
  def num_questions
    n = 0
    self.sections.each do |s|
      n+= s.questions.size()
    end
    n
  end
end
