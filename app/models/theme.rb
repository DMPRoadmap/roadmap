class Theme < ActiveRecord::Base

  ##
  # Associations
  has_and_belongs_to_many :questions, join_table: "questions_themes"
  has_and_belongs_to_many :guidances, join_table: "themes_in_guidance"

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :guidance_ids , :as => [:default, :admin]
  attr_accessible :question_ids, :as => [:default, :admin]
  attr_accessible :description, :title, :locale , :as => [:default, :admin]


  validates :title, presence: {message: _("can't be blank")}

  scope :search, -> (term) {
    search_pattern = "%#{term}%"
    where("title LIKE ? OR description LIKE ?", search_pattern, search_pattern)
  }
  ##
  # returns the title of the theme
  #
  # @return [String] title of the theme
  def to_s
  	title
  end

end
