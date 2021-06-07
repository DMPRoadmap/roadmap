# frozen_string_literal: true

# == Schema Information
#
# Table name: fos
#
#  id         :bigint(8)        not null, primary key
#  identifier :string(255)      not null
#  keywords   :text(65535)
#  label      :string(255)      not null
#  uri        :string(255)      default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :bigint(8)
#
# Indexes
#
#  index_fos_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => fos.id)
#
class FieldOfScience < ApplicationRecord

  self.table_name = "fos"

  STOP_WORDS = [", ", ".", " a ", " an ", " and ", " of ", " or ", " science", " sciences", " the "]

  # ================
  # = Associations =
  # ================

  # Self join
  has_many :sub_fields, class_name: "FieldOfScience", foreign_key: "parent_id"
  belongs_to :parent, class_name: "FieldOfScience", optional: true

  # =================
  # = Class Methods =
  # =================

  class << self

    # Map some text values into FieldOfScience matches using keywords
    def from_text(text:)
      words = text.downcase.split(" ").reject { |word| STOP_WORDS.include?(word) }
      # Return any matches that the text has with the keywords for each field of science
      matches = all.select { |fos| (fos.keywords & words).any? }
    end

  end

  # ====================
  # = Instance Methods =
  # ====================

  # Return all of the keywords along with any keywords from children
  def keywords
    Rails.cache.fetch("field_of_science/#{id}/keywords", expires_in: 4.hours) do
      out = super&.downcase&.split(" ")&.uniq || []
      # Convert the label into keywords
      out += label.downcase.split(" ").reject { |word| STOP_WORDS.include?(word) }
      out += sub_fields.map(&:keywords)
      out.flatten.uniq.compact
    end
  end

end
