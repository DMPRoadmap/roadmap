class Annotation < ActiveRecord::Base
  enum type: [ :example_answer, :guidance]
  ##
  # Associations
  belongs_to :org
  belongs_to :question
  has_one :section, through: :question
  has_one :phase, through: :question
  has_one :template, through: :question

  ##
  # I liked type as the name for the enum so overriding inheritance column
  self.inheritance_column = nil

  validates :question, :org,  presence: {message: _("can't be blank")}

  ##
  # returns the text from the annotation
  #
  # @return [String] the text from the annotation
  def to_s
    "#{text}"
  end


  ##
  # deep copy the given annotation and all it's associations
  #
  # @params [Annotation] annotation to be deep copied
  # @return [Annotation] the saved, copied annotation
  def self.deep_copy(annotation)
    annotation_copy = annotation.dup
    annotation_copy.save!
    return annotation_copy
  end

  def deep_copy(**options)
    copy = self.dup
    copy.question_id = options.fetch(:question_id, nil)
    return copy
  end
end
