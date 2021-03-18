# frozen_string_literal: true

class MetadataStandard < ApplicationRecord

  # ================
  # = Associations =
  # ================

  has_many :research_outputs

  has_and_belongs_to_many :metadata_categories, join_table: "metadata_categories_standards"

  # Self join
  has_many :sub_categories, class_name: "MetadataStandard", foreign_key: "parent_id"
  belongs_to :parent, class_name: "MetadataStandard", optional: true
end