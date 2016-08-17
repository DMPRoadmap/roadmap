class Organisation < ActiveRecord::Base
  include GlobalHelpers

  extend Dragonfly::Model::Validations

  #associations between tables
  belongs_to :organisation_type
  has_many :guidance_groups
  has_many :dmptemplates
  has_many :sections
  has_many :users, through: :user_org_roles
  has_many :option_warnings
  has_many :suggested_answers
  has_and_belongs_to_many :token_permission_types, join_table: "org_token_permissions"

  has_many :user_org_roles

  belongs_to :parent, :class_name => 'Organisation'

	has_one :language

	has_many :children, :class_name => 'Organisation', :foreign_key => 'parent_id'

#	accepts_nested_attributes_for :organisation_type
	accepts_nested_attributes_for :dmptemplates
  accepts_nested_attributes_for :token_permission_types

	attr_accessible :abbreviation, :banner_text, :logo, :remove_logo, :description, :domain, 
                  :logo_file_name, :name, :stylesheet_file_id, :target_url, 
                  :organisation_type_id, :wayfless_entity, :parent_id, :sort_name,
                  :token_permission_type_ids, :language_id

  # allow validations for logo upload
  dragonfly_accessor :logo
  validates_property :height, of: :logo, in: (0..100)
  validates_property :format, of: :logo, in: ['jpeg', 'png', 'gif','jpg','bmp']
  validates_size_of :logo, maximum: 500.kilobytes

	def to_s
		name
	end

  ##
  # returns the name of the organisation
  #
  # @return [String]
  def to_s
    name
  end

  ##
  # returns the abbreviation for the organisation if it exists, or the name if not
  #
  # @return [String] name or abbreviation of the organisation
  def short_name
    if abbreviation.nil? then
      return name
    else
      return abbreviation
    end
  end

  ##
  # finds all organisations who have a parent of the passed organisation type
  #
  # @params [String] the name of an organisation type
  # @return [Array<Organisation>]
  def self.orgs_with_parent_of_type(org_type)
    parents = OrganisationType.find_by_name(org_type).organisations
    children = Array.new
    parents.each do |parent|
        children += parent.children
    end
    return children
  end

  ##
  # returns a list of all guidance groups belonging to other organisations
  #
  # @return [Array<GuidanceGroup>]
  def self.other_organisations
    org_types = [GlobalHelpers.constant("organisation_types.funder")]
    organisations_list = []
    org_types.each do |ot|
      new_org_obejct = OrganisationType.find_by_name(ot)

      org_with_guidance = GuidanceGroup.joins(new_org_obejct.organisations)

      organisations_list = organisations_list + org_with_guidance
    end
    return organisations_list
  end


  ##
  # returns a list of all guidance groups belonging to other organisations
  #
  # @return [Array<GuidanceGroup>]
	def self.other_organisations
		org_types = [GlobalHelpers.constant("organisation_types.funder")]
		organisations_list = []
		org_types.each do |ot|
			new_org_obejct = OrganisationType.find_by_name(ot)

			org_with_guidance = GuidanceGroup.joins(new_org_obejct.organisations)

			organisations_list = organisations_list + org_with_guidance
		end
		return organisations_list
	end

  ##
  # returns a list of all sections of a given version from this organisation and it's parents
  #
  # @params version_id [Integer] version number of the section
  # @return [Array<Section>] list of sections
	def all_sections(version_id)
		if parent.nil?
			secs = sections.where("version_id = ?", version_id)
			if secs.nil? then
				secs = Array.new
			end
			return secs
		else
			return sections.where("version_id = ? ", version_id).all + parent.all_sections(version_id)
		end
	end

  ##
  # returns the guidance groups of this organisation and all of it's children
  #
  # @return [Array<GuidanceGroup>] list of guidance groups
	def all_guidance_groups
		ggs = guidance_groups
		children.each do |c|
			ggs = ggs + c.all_guidance_groups
		end
		return ggs
	end

  ##
  # returns the highest parent organisation in the tree
  #
  # @return [organisation] the root organisation
	def root
		if parent.nil?
			return self
		else
			return parent.root
		end
	end

  ##
  # takes in the id of, and returns an OptionWarning
  #
  # @params option_id [number] the id of the desired warning
  # @return [OptionWarning] the specified warning
	def warning(option_id)
		warning = option_warnings.find_by_option_id(option_id)
		if warning.nil? && !parent.nil? then
			return parent.warning(option_id)
		else
			return warning
		end
	end

  ##
  # returns all published templates belonging to the organisation
  #
  # @return [Array<Dmptemplate>] published dmptemplates
	def published_templates
		return dmptemplates.where("published = ?", 1)
	end

  def check_api_credentials
    if token_permission_types.count == 0
      users.each do |user|
        user.api_token = ""
        user.save!
      end
    end
  end
end
