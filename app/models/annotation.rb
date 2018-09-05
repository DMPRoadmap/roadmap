# == Schema Information
#
# Table name: annotations
#
#  id             :integer          not null, primary key
#  text           :text
#  type           :integer          default(0), not null
#  created_at     :datetime
#  updated_at     :datetime
#  org_id         :integer
#  question_id    :integer
#  versionable_id :string(36)
#
# Indexes
#
#  index_annotations_on_question_id     (question_id)
#  index_annotations_on_versionable_id  (versionable_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (question_id => questions.id)
#

class Annotation < ActiveRecord::Base
  include ValidationMessages
  include VersionableModel

  ##
  # I liked type as the name for the enum so overriding inheritance column
  self.inheritance_column = nil

  enum type: [ :example_answer, :guidance]

  # ================
  # = Associations =
  # ================

  belongs_to :org
  belongs_to :question
  has_one :section, through: :question
  has_one :phase, through: :question
  has_one :template, through: :question

  # ===============
  # = Validations =
  # ===============

  validates :text, presence: { message: PRESENCE_MESSAGE }

  validates :org, presence: { message: PRESENCE_MESSAGE }

  validates :question, presence: { message: PRESENCE_MESSAGE }

  validates :type, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE,
                                 scope: [:question_id, :org_id] }


  # =================
  # = Class Methods =
  # =================

  # Deep copy the given annotation and all it's associations
  #
  # annotation - To be deep copied
  #
  # Returns Annotation
  def self.deep_copy(annotation)
    annotation_copy = annotation.dup
    annotation_copy.save!
    return annotation_copy
  end

  # ===========================
  # = Public instance methods =
  # ===========================

  # The text from the annotation
  #
  # Returns String
  def to_s
    "#{text}"
  end

  def deep_copy(**options)
    copy = self.dup
    copy.question_id = options.fetch(:question_id, nil)
    return copy
  end
end
