# frozen_string_literal: true

class FieldOfScience < ApplicationRecord

  self.table_name = "fos"

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :metadata_standards, join_table: "fos_metadata_standards"
  has_and_belongs_to_many :repositories, join_table: "fos_repositories"

  # Self join
  has_many :sub_fields, class_name: "FieldOfScience", foreign_key: "parent_id"
  belongs_to :parent, class_name: "FieldOfScience", optional: true

  # =================
  # = Class Methods =
  # =================

  class << self

    # Map an RDAMSC title to a Field Of Science
    #   e.g. "AVM (Astronomy Visualization Metadata)", "Dublin Core", etc.
    def from_text(text:)
      matches = []
      return matches unless text.present?

      # 1 - Natural sciences
      %w[astronom observatory crystallograph geolog geospatial natural telescope].each do |frag|
        matches << find_by(identifier: "1") if text.downcase.include?(frag)
      end
      # 1.5 - Earth and related environmental sciences
      %w[earth ecolog environ climat ocean coastal marine meteorol].each do |frag|
        matches << find_by(identifier: "1.5") if text.downcase.include?(frag)
      end
      # 1.6 - Biological sciences
      %w[biolog molecul genome genetic protein dna germ].each do |frag|
        matches << find_by(identifier: "1.6") if text.downcase.include?(frag)
      end
      # 2 - Engineering and Technology
      %w[engineer technol electric mechanic chemic materials].each do |frag|
        matches << find_by(identifier: "2") if text.downcase.include?(frag)
      end
      # 3 - Medical and Health Sciences
      %w[healthcare medic molecul genome genetic protein dna germ].each do |frag|
        matches << find_by(identifier: "3") if text.downcase.include?(frag)
      end
      # 4 - Agricultural Sciences
      %w[agricultur herb plant].each do |frag|
        matches << find_by(identifier: "4") if text.downcase.include?(frag)
      end
      # 5 - Social Sciences
      %w[social legal politic psycholog economic educational communications].each do |frag|
        matches << find_by(identifier: "5") if text.downcase.include?(frag)
      end
      # 6 - Humanities
      %w[humanit history archeolog linguist philosoph theolog religio music].each do |frag|
        matches << find_by(identifier: "6") if text.downcase.include?(frag)
      end

      matches.flatten.uniq.compact
    end

    private

    STOP_WORDS = %w[a an and basic information metadata of or science the]

    def from_keyword(keywords:)
      matches = []
      keywords.split(" ").map { |word| word.downcase }.each do |keyword|
        next if STOP_WORDS.include?(keyword)

        matches += where("label LIKE ?", "%#{keyword}%")
      end


      matches.flatten.uniq.compact&.sort { |a, b| a&.identifier <=> b&.identifier }
    end

  end

end