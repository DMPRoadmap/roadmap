class QuestionFormat < ActiveRecord::Base
  attr_accessible :title, :description, :as => [:default, :admin]

  #associations between tables
  has_many :questions
  
  validates :title, presence: true, uniqueness: true
  
  ##
  # gives the title of the question_format
  #
  # @return [String] title of the question_format
  def to_s
    "#{title}"
  end

end