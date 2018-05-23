class Org < ActiveRecord::Base
  include GlobalHelpers
  include FlagShihTzu
  extend Dragonfly::Model::Validations
  validates_with OrgLinksValidator

  # Stores links as an JSON object: { org: [{"link":"www.example.com","text":"foo"}, ...] }
  # The links are validated against custom validator allocated at validators/template_links_validator.rb
  serialize :links, JSON

  ##
  # Associations
#  belongs_to :organisation_type   # depricated, but cannot be removed until migration run
  belongs_to :language
  has_many :guidance_groups
  has_many :templates
  has_many :users
  has_many :annotations

  has_and_belongs_to_many :token_permission_types, join_table: "org_token_permissions", unique: true

  has_many :org_identifiers
  has_many :identifier_schemes, through: :org_identifiers

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
	attr_accessible :abbreviation, :logo, :remove_logo,
                  :logo_file_name, :name, :links,
                  :organisation_type_id, :wayfless_entity, :parent_id, :sort_name,
                  :token_permission_type_ids, :language_id, :contact_email, :contact_name,
                  :language, :org_type, :region, :token_permission_types,
                  :guidance_group_ids, :is_other, :region_id, :logo_uid, :logo_name,
                  :feedback_enabled, :feedback_email_subject, :feedback_email_msg
  ##
  # Validators
#  validates :contact_email, email: true, allow_nil: true
  validates :name, presence: {message: _("can't be blank")}, uniqueness: {message: _("must be unique")}
  # allow validations for logo upload
  dragonfly_accessor :logo do
    after_assign :resize_image
  end
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

  scope :search, -> (term) {
    search_pattern = "%#{term}%"
    where("orgs.name LIKE ? OR orgs.contact_email LIKE ?", search_pattern, search_pattern)
  }

  after_create :create_guidance_group

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
  def org_type_to_s
    ret = []
    ret << "Institution" if self.institution?
    ret << "Funder" if self.funder?
    ret << "Organisation" if self.organisation?
    ret << "Research Institute" if self.research_institute?
    ret << "Project" if self.project?
    ret << "School" if self.school?
    return (ret.length > 0 ? ret.join(', ') : "None")
  end

  def funder_only?
    self.org_type == Org.org_type_values_for(:funder).min
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
  # returns all published templates belonging to the organisation
  #
  # @return [Array<Template>] published templates
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

  def org_admins
    User.joins(:perms).where("users.org_id = ? AND perms.name IN (?)", self.id,
      ['grant_permissions', 'modify_templates', 'modify_guidance', 'change_org_details'])
  end

  def plans
    Plan.includes(:template, :phases, :roles, :users).joins(:roles, :users).where('users.org_id = ? AND roles.access IN (?)',
      self.id, Role.access_values_for(:owner).concat(Role.access_values_for(:administrator)))
  end
  
  def grant_api!(token_permission_type)
    self.token_permission_types << token_permission_type unless self.token_permission_types.include? token_permission_type
  end
  
  # DMPTool participating institution helpers
  def self.participating
    shibbolized = Org.joins(:identifier_schemes).where('is_other IS NULL').pluck(:id)
    non_shibbolized = Org.where('orgs.is_other IS NULL AND orgs.id NOT IN (?)', shibbolized).pluck(:id)
    Org.includes(:identifier_schemes).where(id: (shibbolized + non_shibbolized).flatten.uniq)
  end
  def self.participating_as_array
    shibbolized = Org.joins(:identifier_schemes).where('is_other IS NULL')
    non_shibbolized = Org.where('orgs.is_other IS NULL AND orgs.id NOT IN (?)', shibbolized.collect(&:id))
    (shibbolized.to_a + non_shibbolized.to_a)
  end
  def shibbolized?
    self.org_identifiers.where(identifier_scheme: IdentifierScheme.find_by(name: 'shibboleth')).present?
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

    # creates a dfefault Guidance Group on create on the Org
    def create_guidance_group
      GuidanceGroup.create(name: self.abbreviation? ? self.abbreviation : self.name , org_id: self.id)
    end

end
