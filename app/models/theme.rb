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

  scope :sorted_by_translated_title, -> {
    all.each { |theme|
      theme[:title] = _(theme[:title])
    }.sort_by { |theme| theme[:title] } 
  }


  # ===========================
  # = Public instance methods =
  # ===========================

  # title and description are translated through the translation gem
  def title
    title = read_attribute(:title)
    _(title) unless title.blank?
  end

  def description
    description = read_attribute(:description)
    _(description) unless description.blank?
  end

  # The title of the Theme
  #
  # Returns String
  def to_s
    title
  end

end
