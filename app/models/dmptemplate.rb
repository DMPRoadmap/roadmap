class Dmptemplate < ActiveRecord::Base
    include GlobalHelpers

    attr_accessible :id, :organisation_id, :description, :published, :title, :user_id, :locale, 
                    :is_default, :guidance_group_ids, :as => [:default, :admin] 

    #associations between tables
    has_many :phases
    has_many :versions, through: :phases
    has_many :sections, through: :versions
    has_many :questions, through: :sections
    has_many :projects

    #has_many :guidances                needs to be removed and checked

    belongs_to :organisation

	has_and_belongs_to_many :guidance_groups, join_table: "dmptemplates_guidance_groups"

    accepts_nested_attributes_for :guidance_groups
    accepts_nested_attributes_for :phases
    accepts_nested_attributes_for :organisation
    accepts_nested_attributes_for :projects


  has_settings :export, class_name: 'Settings::Dmptemplate' do |s|
    s.key :export, defaults: Settings::Dmptemplate::DEFAULT_SETTINGS
  end

  ##
  # Converts a DMPtemplate object into a string containing it's title
  #
  # @return [String] the title of the DMPtemplate
  def to_s
    "#{title}"
  end

  ##
  # takes a type or organisation and returns all published templates from
  # organisations of that type
  #
  # @param ot [String] name of an organisation type e.g. founder
  # @return [Array<dmptemplates>] list of published dmptemplates
  def self.templates_org_type(ot)
    # DISCUSS - This function other than the check for the template being published
    # is a superclass for the below funders_templates
    new_org_obejcts = OrganisationType.find_by( name: ot ).organisations

    org_templates = Array.new
    new_org_obejcts.each do |neworg|
       org_templates += neworg.dmptemplates.where("published = ?", true)
    end

    return org_templates
  end

  ##
	# returns all templates from all organisations of the Organisation_Type funder
  #
  # @return [Array<dmptemplates>] all templates from funder organisations
	def self.funders_templates
		new_org_obejcts = OrganisationType.find_by(name: GlobalHelpers.constant("organisation_types.funder")).organisations
	  org_templates = Array.new

   	new_org_obejcts.each do |neworg|
       	org_templates += neworg.dmptemplates
    end

    return org_templates
	end

  ##
	# returns all institutional templates bellowing to the given organisation
  #
  # @param org_id [integer] the integer id for an organisation
  # @return [Array<dmptemplates>] all templates from a user's organisation
	def self.own_institutional_templates(org_id)
    # DISCUSS - Why is this done by scanning organisation_id's from the templates
    # yet all other calls are done by finding an organisation, and using the
    # has_many relationship to find the dmptemplates?
    # - A possible answer is that there may be deleted organisations which we are
    # serching for templates for.
    # - A standardised behavior on querries, wether through active reccord or the
    # where, should maybe be thought of/decided upon
		new_templates = self.where("organisation_id = ?", org_id)
		return new_templates
	end

  ##
	# returns an array with all funders and of the given organisations's
  # institutional templates
  #
  # @param org_id [integer] the integer id for an organisation
  # @return [Array<dmptemplates>] all templates from the template's organisation
  #   or from a funder organisation
	def self.funders_and_own_templates(org_id)
		funders_templates = self.funders_templates
    # DISCUSS - Here we internationalise the word funder.  There is code in the
    # api that just uses the english word funder.  Why are we internationalising
    # the database querry, and do I need to change things like this elsewhere?

    #verify if org type is not a funder
    current_org = Organisation.find(org_id)
    if current_org.organisation_type.name != GlobalHelpers.constant("organisation_types.funder") then
      own_institutional_templates = self.own_institutional_templates(org_id)
    else
      own_institutional_templates = []
    end

		templates_list = Array.new
		templates_list += own_institutional_templates
		templates_list += funders_templates
		templates_list = templates_list.sort_by { |f| f['title'].downcase }

		return templates_list
	end

  ##
  # Returns the string name of the organisation type of the organisation who
  # owns this dmptemplate
  #
  # @return [string] the string name of an organisation type
	def org_type
		org_type = organisation.organisation_type.name
		return org_type
	end

  ##
	# Verify if a template has customisation by given organisation
  #
  # @param org_id [integer] the integer id for an organisation
  # @param temp [dmptemplate] a template object
  # @return [Boolean] true if temp has customisation by the given organisation
	def has_customisations?(org_id, temp)
    # EXPLAIN - I dont Understand the data model here.  If the template isnt
    # owned by the organisation, how can it make changes to a section?
    # Why cant the owner make customisations?
		if temp.organisation_id != org_id then
			temp.phases.each do |phase|
				phase.versions.each do |version|
					version.sections.each do |section|
						return true if section.organisation_id == org_id
					end
				end
				return false
			end
		else
			return false
		end
	end

  ##
	# verify if there are any publish version for the template
  #
  # @return [Boolean] true if there is a published version for the template
	def has_published_versions?
		phases.each do |phase|
			return true if !phase.latest_published_version.nil?
		end
		return false 
	end

end
