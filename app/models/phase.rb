# [+Project:+] DMPRoadmap
# [+Description:+] This model describes informmation about the phase of a plan, it's title, order of display and which template it belongs to.
#
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center
class Phase < ActiveRecord::Base

  extend FriendlyId

  #associations between tables
  belongs_to :dmptemplate

# TODO: We shouldn't be short-cutting access to grandchildren and great grandchildren
  has_many :versions, :dependent => :destroy
  has_many :sections, :through => :versions, :dependent => :destroy
  has_many :questions, :through => :sections, :dependent => :destroy

# TODO: REMOVE AND HANDLE ATTRIBUTE SECURITY IN THE CONTROLLER!
  #Link the child's data
  accepts_nested_attributes_for :versions, :allow_destroy => true 
#  accepts_nested_attributes_for :dmptemplate

# TODO: REMOVE AND HANDLE ATTRIBUTE SECURITY IN THE CONTROLLER!
  attr_accessible :description, :number, :title, :versions, :dmptemplate,
                  :dmptemplate_id, :versions, :as => [:default, :admin]

  friendly_id :title, use: [:slugged, :history, :finders]

  validates :title, :number, :dmptemplate, presence: true

  ##
  # returns the title of the phase
  #
  # @return [String] the title of the phase
  def to_s
    "#{title}"
  end

  ##
  # returns either the latest published version of this phase
  # also serves to verify if this phase has any published versions as returns nil
  # if there are no published versions
  #
  # @return [Version, nil]
  def latest_published_version
    pub_vers = versions.where('published = ?', true).order('updated_at DESC')
    if pub_vers.any?() then
      return pub_vers.first
    else
      return nil
    end
  end

# TODO: reevaluate this method. It seems like the 1st query is unecessary
  ##
  # verify if a phase has a published version or a version with one or more sections
  #
  # @return [Boolean]
  def has_sections
    versions = self.versions.where('published = ?', true).order('updated_at DESC')
    if versions.any? then
      version = versions.first
      if !version.sections.empty? then
        has_section = true
      else
        has_section = false
      end
    else
      version = self.versions.order('updated_at DESC').first 
      if !version.sections.empty? then
        has_section = true
      else
        has_section = false
      end
    end
    return has_section
  end
end
