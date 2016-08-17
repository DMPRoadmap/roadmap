class Version < ActiveRecord::Base

  #associations between tables
  belongs_to :phase

  has_many :sections, :dependent => :destroy
  has_many :questions, :through => :sections, :dependent => :destroy
  has_many :plans

  #Link the data
#  accepts_nested_attributes_for :phase
  accepts_nested_attributes_for :sections,  :allow_destroy => true

  attr_accessible :id, :description, :number, :published, :title, :phase_id,
                  :sections_attributes, :as => [:default, :admin]

  ##
  # returns the title of the version
  #
  # @return [String] the title of the version
  def to_s
  	"#{title}"
  end


  ##
  # returns all sections where the org_id is the same as this version's phase's org_id
  #
  # @return [Array<Section>]
  def global_sections
  	sections.where("organisation_id = ? ", phase.dmptemplate.organisation_id).load
  end

  amoeba do
    include_association :sections
    include_association :questions
    set :published => 'false'
    prepend :title => "Copy of "
  end

end
