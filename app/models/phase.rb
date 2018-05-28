# [+Project:+] DMPRoadmap
# [+Description:+] This model describes informmation about the phase of a plan, it's title, order of display and which template it belongs to.
#
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center
class Phase < ActiveRecord::Base
  ##
  # Sort order: Number ASC
  default_scope { order(number: :asc) }

  ##
  # Associations
  belongs_to :template
  has_many :sections, -> { order(:number => :asc) }, dependent: :destroy

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :description, :number, :title, :template_id, 
                  :template, :sections, :modifiable, :as => [:default, :admin]

  validates :title, :number, :template, presence: {message: _("can't be blank")}

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
    options[:phase_id] = id
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
    return n
  end
end
