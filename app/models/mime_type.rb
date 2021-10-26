# frozen_string_literal: true

# == Schema Information
#
# Table name: mime_types
#
#  id          :bigint           not null, primary key
#  category    :string           not null
#  description :string           not null
#  value       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_mime_types_on_value  (value)
#
class MimeType < ApplicationRecord

  include ValidationMessages

  # ================
  # = Associations =
  # ================

  has_many :research_outputs

  # ===============
  # = Validations =
  # ===============

  validates :category, :description, :value, presence: { message: PRESENCE_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  # Retrieves the unique list of categories
  scope :categories, -> { pluck(:category).uniq.sort { |a, b| a <=> b } }

end
