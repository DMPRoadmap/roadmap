class Annotation < ActiveRecord::Base
  enum type: [:example_answer, :guidance]
  ##
  # Associations
  belongs_to :org
  belongs_to :question

  ##
  # I liked type as the name for the enum so overriding inheritance column
  self.inheritance_column = nil

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :org_id, :question_id, :text, :type,
                  :org, :question, :as => [:default, :admin]


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
end