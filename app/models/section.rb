class Section < ActiveRecord::Base
  ##
  # Associations
  belongs_to :phase
  belongs_to :organisation
  has_many :questions, :dependent => :destroy
  has_one :template, through: :phase

  #Link the data
  accepts_nested_attributes_for :questions, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true

  attr_accessible :phase_id, :description, :number, :title, :published,
                  :questions_attributes, :organisation, :phase, :modifiable,
                  :as => [:default, :admin]

  validates :phase, :title, :number, presence: {message: _("can't be blank")}

  before_validation :set_defaults

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
    questions_hash = questions.reduce({}){ |m, q| m[q.id] = q; m }
    return plan.answers.includes({ question: :question_format }, :question_options).reduce(0) do |m, a|
      if questions_hash[a.question_id].present? && a.is_valid?
        m+= 1
      end
      m
    end
  end

  def deep_copy(**options)
    copy = self.dup
    copy.modifiable = options.fetch(:modifiable, self.modifiable)
    copy.phase_id = options.fetch(:phase_id, nil)
    copy.save!(validate: false)  if options.fetch(:save, false)
    options[:section_id] = id
    self.questions.map{ |question| copy.questions << question.deep_copy(options) }
    return copy
  end

  private
    def set_defaults
      self.modifiable = true if modifiable.nil?
    end
end
