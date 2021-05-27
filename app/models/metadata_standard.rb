# frozen_string_literal: true

class MetadataStandard < ApplicationRecord

  # ================
  # = Associations =
  # ================

  has_many :research_outputs

  has_and_belongs_to_many :fields_of_science, join_table: "fos_metadata_standards",
                                              association_foreign_key: "fos_id",
                                              class_name: "FieldOfScience"

  # Self join
  has_many :sub_categories, class_name: "MetadataStandard", foreign_key: "parent_id"
  belongs_to :parent, class_name: "MetadataStandard", optional: true
end