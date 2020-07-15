# frozen_string_literal: true

# == Schema Information
#
# Table name: themes
#
#  id          :integer          not null, primary key
#  description :text
#  locale      :string
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Theme < ApplicationRecord

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :questions, join_table: "questions_themes"
  has_and_belongs_to_many :guidances, join_table: "themes_in_guidance"

  # ===============
  # = Validations =
  # ===============

  validates :title, presence: { message: PRESENCE_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    where("lower(title) LIKE lower(?) OR description LIKE lower(?)",
          search_pattern, search_pattern)
  }

  # ===========================
  # = Public instance methods =
  # ===========================

  # The title of the Theme
  #
  # Returns String
  def to_s
    title
  end

end
