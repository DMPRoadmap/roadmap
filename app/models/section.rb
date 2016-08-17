class Section < ActiveRecord::Base

  #associations between tables
  belongs_to :version
  belongs_to :organisation
  has_many :questions, :dependent => :destroy
  has_many :plan_sections, :dependent => :destroy

  #Link the data
  accepts_nested_attributes_for :questions, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true
#  accepts_nested_attributes_for :version

  attr_accessible :organisation_id, :description, :number, :title, :version_id , :published, :questions_attributes, :as => [:default, :admin]

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
