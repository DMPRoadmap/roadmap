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

class Theme < ActiveRecord::Base
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :questions, join_table: "questions_themes"
  has_and_belongs_to_many :guidances, join_table: "themes_in_guidance"

  # ===============
  # = Validations =
  # ===============

  validates :title, presence: { message: PRESENCE_MESSAGE }

  validates :description, presence: { message: PRESENCE_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  scope :search, -> (term) {
    search_pattern = "%#{term}%"
    where("title LIKE ? OR description LIKE ?", search_pattern, search_pattern)
  }

  # ===========================
  # = Public instance methods =
  # ===========================

  ##
  # returns the title of the theme
  #
  # @return [String] title of the theme
  def to_s
  	title
  end
end
