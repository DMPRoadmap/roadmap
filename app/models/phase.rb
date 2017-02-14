# [+Project:+] DMPRoadmap
# [+Description:+] This model describes informmation about the phase of a plan, it's title, order of display and which template it belongs to.
#
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center
class Phase < ActiveRecord::Base
	#extend FriendlyId

	##
  # Associations
	belongs_to :template
	has_many :sections, dependent: :destroy
  has_many :questions, :through => :sections, dependent: :destroy

	##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
	attr_accessible :description, :number, :title, :template_id, 
                  :template, :sections, :modifiable, :as => [:default, :admin]

  ##
  # sluggable title
	#friendly_id :title, use: [:slugged, :history, :finders]


  validates :title, :number, :template, presence: true






  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?





  ##
  # returns the title of the phase
  #
  # @return [String] the title of the phase
  def to_s
    "#{title}"
  end

# TODO: This function does not belong here anymore. It may be useless now.
  ##
  # returns either the latest published version of this phase
  # also serves to verify if this phase has any published versions as returns nil
  # if there are no published versions
  #
  # @return [Version, nil]
#  def latest_published_version
#    pub_vers = versions.where('published = ?', true).order('updated_at DESC')
#    if pub_vers.any?() then
#      return pub_vers.first
#    else
#      return nil
#    end
#  end

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

  ##
  # deep copy the given phase and all it's associations
  #
  # @params [Phase] phase to be deep copied
  # @return [Phase] the saved, copied phase
  def self.deep_copy(phase)
    phase_copy = phase.dup
    phase_copy.save!
    phase.sections.each do |section|
      section_copy = Section.deep_copy(section)
      section_copy.phase_id = phase_copy.id
      section_copy.save!
    end
    return phase_copy
  end
end
