class Org < ActiveRecord::Base
  include GlobalHelpers
  include FlagShihTzu
  extend Dragonfly::Model::Validations

  ##
  # Sort order: Name ASC
  default_scope { order(name: :asc) }


  ##
  # Associations
#  belongs_to :organisation_type   # depricated, but cannot be removed until migration run
  belongs_to :language
  has_many :guidance_groups
  has_many :templates
  has_many :users
  has_many :annotations
  
  has_and_belongs_to_many :token_permission_types, join_table: "org_token_permissions", unique: true

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
	attr_accessible :abbreviation, :banner_text, :logo, :remove_logo,
                  :logo_file_name, :name, :target_url,
                  :organisation_type_id, :wayfless_entity, :parent_id, :sort_name,
                  :token_permission_type_ids, :language_id, :contact_email, 
                  :language, :org_type, :region, :token_permission_types

  ##
  # Validators
  validates :contact_email, email: true, allow_nil: true
  validates :name, presence: {message: _("can't be blank")}, uniqueness: {message: _("must be unique")}
  # allow validations for logo upload
  dragonfly_accessor :logo do
    after_assign :resize_image
  end
  validates_property :height, of: :logo, in: (0..100), message: _("height must be less than 100px")
  validates_property :format, of: :logo, in: ['jpeg', 'png', 'gif','jpg','bmp'], message: _("must be one of the following formats: jpeg, jpg, png, gif, bmp")
  validates_size_of :logo, maximum: 500.kilobytes, message: _("can't be larger than 500KB")

  ##
  # Define Bit Field values
  # Column org_type
  has_flags 1 => :institution,
            2 => :funder,
            3 => :organisation,
            4 => :research_institute,
            5 => :project,
            6 => :school,
            column: 'org_type'

  # Predefined queries for retrieving the managain organisation and funders
  scope :managing_orgs, -> { where(abbreviation: Rails.configuration.branding[:organisation][:abbreviation]) }
  scope :funders, -> { where(org_type: 2) }
  scope :institutions, -> { where(org_type: 1) }


  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?

  # Determines the locale set for the organisation
  # @return String or nil 
  def get_locale
    if !self.language.nil?
      return self.language.abbreviation
    else
      return nil
    end
  end

# TODO: Should these be hardcoded? Also, an Org can currently be multiple org_types at one time.
#       For example you can do: funder = true; project = true; school = true
#       Calling type in the above scenario returns "Funder" which is a bit misleading
#       Is FlagShihTzu's Bit flag the appropriate structure here or should we use an enum?
#       Tests are setup currently to work with this issue.
  ##
  # returns the name of the type of the organisation as a string
  # defaults to none if no org type present
  #
  # @return [String]
  def type
    if self.institution?
      return "Institution"
    elsif self.funder?
      return "Funder"
    elsif self.organisation?
      return "Organisation"
    elsif self.research_institute?
      return "Research Institute"
    elsif self.project?
      return "Project"
    elsif self.school?
      return "School"
    end
      return "None"
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
  # @param [String] the name of an organisation type
  # @return [Array<Organisation>]
=begin
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
  # @param version_id [Integer] version number of the section
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
=end
  
  ##
  # returns all published templates belonging to the organisation
  #
  # @return [Array<Dmptemplate>] published dmptemplates
	def published_templates
		return templates.where("published = ?", true)
	end

  def check_api_credentials
    if token_permission_types.count == 0
      users.each do |user|
        user.api_token = ""
        user.save!
      end
    end
  end
  
  private
    ##
    # checks size of logo and resizes if necessary
    #
    def resize_image
      unless logo.nil?
        if logo.height != 100
          self.logo = logo.thumb('x100')  # resize height and maintain aspect ratio
        end
      end
    end 
end
