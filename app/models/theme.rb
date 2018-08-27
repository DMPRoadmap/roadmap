# == Schema Information
#
# Table name: themes
#
#  id          :integer          not null, primary key
#  description :text(65535)
#  locale      :string(255)
#  title       :string(255)
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

  # The title of the Theme
  #
  # Returns String
  def to_s
  	title
  end
end
