# == Schema Information
#
# Table name: annotations
#
#  id          :integer          not null, primary key
#  text        :text
#  type        :integer          default(0), not null
#  created_at  :datetime
#  updated_at  :datetime
#  org_id      :integer
#  question_id :integer
#
# Indexes
#
#  index_annotations_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (question_id => questions.id)
#

class Annotation < ActiveRecord::Base
  include ValidationMessages

  enum type: [ :example_answer, :guidance]

  # ================
  # = Associations =
  # ================

  belongs_to :org
  belongs_to :question
  has_one :section, through: :question
  has_one :phase, through: :question
  has_one :template, through: :question

  ##
  # I liked type as the name for the enum so overriding inheritance column
  self.inheritance_column = nil

  # ===============
  # = Validations =
  # ===============

  validates :text, presence: { message: PRESENCE_MESSAGE }

  validates :org, presence: { message: PRESENCE_MESSAGE }

  validates :question, presence: { message: PRESENCE_MESSAGE }

  validates :type, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE,
                                 scope: :question_id }

  # =================
  # = Class Methods =
  # =================

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

  # ===========================
  # = Public instance methods =
  # ===========================

  ##
  # returns the text from the annotation
  #
  # @return [String] the text from the annotation
  def to_s
    "#{text}"
  end

  def deep_copy(**options)
    copy = self.dup
    copy.question_id = options.fetch(:question_id, nil)
    return copy
  end
end
