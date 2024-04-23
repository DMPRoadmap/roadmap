# frozen_string_literal: true

# == Schema Information
#
# Table name: annotations
#
#  id             :integer          not null, primary key
#  text           :text
#  type           :integer          default("example_answer"), not null
#  created_at     :datetime
#  updated_at     :datetime
#  org_id         :integer
#  question_id    :integer
#  versionable_id :string(36)
#
# Indexes
#
#  annotations_org_id_idx               (org_id)
#  annotations_question_id_idx          (question_id)
#  index_annotations_on_versionable_id  (versionable_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (question_id => questions.id)
#

# Object that represents Question level guidance or example answers
class Annotation < ApplicationRecord
  include VersionableModel

  ##
  # I liked type as the name for the enum so overriding inheritance column
  self.inheritance_column = nil

  enum type: %i[example_answer guidance]

  # ================
  # = Associations =
  # ================

  belongs_to :org, optional: true
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
                                 scope: %i[question_id org_id] }

  # =================
  # = Class Methods =
  # =================

  # ===========================
  # = Public instance methods =
  # ===========================

  # The text from the annotation
  #
  # Returns String
  def to_s
    text.to_s
  end

  def deep_copy(**options)
    copy = dup
    copy.question_id = options.fetch(:question_id, nil)
    copy
  end
end
