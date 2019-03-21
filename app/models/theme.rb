# == Schema Information
#
# Table name: themes
#
#  id          :integer          not null, primary key
#  description :text
#  locale      :string(510)
#  slug        :string(510)
#  title       :string(510)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Theme < ActiveRecord::Base
  include ValidationMessages
  include Dmpopidor::Models::Theme


  ##
  # Before save & create, generate the slug, method from Dmpopidor::Models::Theme
  before_save :generate_slug

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :questions, join_table: "questions_themes"
  has_and_belongs_to_many :guidances, join_table: "themes_in_guidance"
  has_many :answers, through: :questions

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
