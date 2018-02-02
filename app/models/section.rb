class Section < ActiveRecord::Base
  ##
  # Associations
  belongs_to :phase
  belongs_to :organisation
  has_many :questions, :dependent => :destroy

  #Link the data
  accepts_nested_attributes_for :questions, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true
#  accepts_nested_attributes_for :version

  attr_accessible :phase_id, :description, :number, :title, :published,
                  :questions_attributes, :organisation, :phase, :modifiable,
                  :as => [:default, :admin]

  validates :phase, :title, :number, presence: {message: _("can't be blank")}

  ##
  # return the title of the section
  #
  # @return [String] the title of the section
  def to_s
    "#{title}"
  end

  # Returns the number of answered questions for a given plan id
  def num_answered_questions(plan)
    questions_hash = questions.reduce({}){ |m, q| m[q.id] = q; m }
    return plan.answers.includes({question: :question_format}, :question_options).reduce(0) do |m, a|
      if questions_hash[a.question_id].present? && a.is_valid?
        m+=1
      end
      m
    end
  end
  ##
  # deep copy of the given section and all it's associations
  #
  # @params [Section] section to be deep copied
  # @return [Section] the saved, copied section
  def self.deep_copy(section)
    section_copy = section.dup
    section_copy.save!
    section.questions.each do |question|
      question_copy = Question.deep_copy(question)
      question_copy.section_id = section_copy.id
      question_copy.save!
    end
    return section_copy
  end
end
