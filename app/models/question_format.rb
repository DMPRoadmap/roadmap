class QuestionFormat < ActiveRecord::Base

  ##
  # Associations
  has_many :questions
  
  validates :title, presence: true, uniqueness: true
  
  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :title, :description, :option_based, :questions, :as => [:default, :admin]


  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?


  ##
  # gives the title of the question_format
  #
  # @return [String] title of the question_format
  def to_s
    "#{title}"
  end

end