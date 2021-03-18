# frozen_string_literal: true

class MetadataCategory < ApplicationRecord

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :metadata_standards, join_table: "metadata_categories_standards"

  # Self join
  has_many :sub_categories, class_name: "MetadataCategory", foreign_key: "parent_id"
  belongs_to :parent, class_name: "MetadataCategory", optional: true
end