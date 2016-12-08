# [+Project:+] DMPRoadmap
# [+Description:+] This model describes informmation about the phase of a plan, it's title, order of display and which template it belongs to.
#
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center
class Phase < ActiveRecord::Base
	extend FriendlyId

	##
  # Associations
	belongs_to :template, dependant: :destroy
	has_many :sections, dependant: :destroy
  has_many :questions, :through => :sections, dependent: :destroy

	##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
	attr_accessible :description, :number, :title, :dmptemplate_id, :as => [:default, :admin]

  ##
  # sluggable title
	friendly_id :title, use: [:slugged, :history, :finders]








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
		pub_vers = versions.where('published = ?', true).order('updated_at DESC')
    if pub_vers.any?() then
      return pub_vers.first
    else
      return nil
    end
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
