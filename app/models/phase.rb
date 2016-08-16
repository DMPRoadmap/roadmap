# [+Project:+] DMPRoadmap
# [+Description:+] This model describes informmation about the phase of a plan, it's title, order of display and which template it belongs to.
#
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center
class Phase < ActiveRecord::Base

	extend FriendlyId

	#associations between tables
	belongs_to :dmptemplate

	has_many :versions, :dependent => :destroy
	has_many :sections, :through => :versions, :dependent => :destroy
  has_many :questions, :through => :sections, :dependent => :destroy

	#Link the child's data
	accepts_nested_attributes_for :versions, :allow_destroy => true 
#	accepts_nested_attributes_for :dmptemplate

	attr_accessible :description, :number, :title, :dmptemplate_id, :as => [:default, :admin]

	friendly_id :title, use: [:slugged, :history, :finders]

  ##
  # returns the title of the phase
  #
  # @return [String] the title of the phase
	def to_s
		"#{title}"
	end

  ##
  # returns the most_recent version of this phase
  #
  # @return [Version] the most recent version of this phase
	def latest_version
		return versions.order("number DESC").last
	end

  ##
	# returns either the latest published version of this phase
  # also serves to verify if this phase has any published versions as returns nil
  # if there are no published versions
  #
  # @return [Version, nil]
	def latest_published_version
		versions.order("number DESC").each do |version|
			if version.published then
				return version
			end
		end
		return nil
	end

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
