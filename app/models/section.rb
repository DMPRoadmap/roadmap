class Section < ActiveRecord::Base

  ##
  # Associations
  belongs_to :phase
  belongs_to :organisation
  has_many :questions, :dependent => :destroy

  #Link the data
  accepts_nested_attributes_for :questions, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true
#  accepts_nested_attributes_for :version

  attr_accessible :organisation_id, :description, :number, :title, :published, :questions_attributes, 
                  :organisation, :modifiable, :phase, :as => [:default, :admin]

  ##
  # return the title of the section
  #
  # @return [String] the title of the section
  def to_s
    "#{title}"
  end

  amoeba do
    include_association :questions
  end

end
