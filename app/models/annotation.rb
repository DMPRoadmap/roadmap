# == Schema Information
#
# Table name: annotations
#
#  id             :integer          not null, primary key
#  question_id    :integer
#  org_id         :integer
#  text           :text
#  type           :integer          default("0"), not null
#  created_at     :datetime
#  updated_at     :datetime
#  versionable_id :string(36)
#
# Indexes
#
#  annotations_org_id_idx               (org_id)
#  annotations_question_id_idx          (question_id)
#  index_annotations_on_versionable_id  (versionable_id)
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
