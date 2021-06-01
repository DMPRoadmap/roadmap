# frozen_string_literal: true

class MetadataStandard < ApplicationRecord

  # ================
  # = Associations =
  # ================

  has_many :research_outputs

  # Self join
  has_many :sub_categories, class_name: "MetadataStandard", foreign_key: "parent_id"
  belongs_to :parent, class_name: "MetadataStandard", optional: true

  # ==========
  # = Scopes =
  # ==========

  scope :disciplinary, -> { where(discipline_specific: true) }

  scope :generic, -> { where(discipline_specific: false) }

  scope :search, lambda { |term|
    where("LOWER(title) LIKE ?", "%#{term}%").or(where("LOWER(description) LIKE ?", "%#{term}%"))
  }

end