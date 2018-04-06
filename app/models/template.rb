class Template < ActiveRecord::Base
  include GlobalHelpers
  include ActiveModel::Validations
  validates_with TemplateLinksValidator

  before_validation :set_creation_defaults

  # Stores links as an JSON object: { funder: [{"link":"www.example.com","text":"foo"}, ...], sample_plan: [{"link":"www.example.com","text":"foo"}, ...]}
  # The links is validated against custom validator allocated at validators/template_links_validator.rb
  serialize :links, JSON
  
  ##
  # Associations
  belongs_to :org
  has_many :plans
  has_many :phases, dependent: :destroy
  has_many :sections, through: :phases
  has_many :questions, through: :sections

  # Self join for Customizations
  has_many :customizations, class_name: 'Template', foreign_key: 'customization_of'
  belongs_to :customized_from, class_name: 'Template'

  # Self join for Siblings/Versions
  has_many :versions, class_name: 'Template', foreign_key: 'family_id'

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :id, :org_id, :description, :published, :title, :locale, :customization_of,
                  :is_default, :guidance_group_ids, :org, :plans, :phases, :family_id,
                  :archived, :version, :visibility, :published, :links, :as => [:default, :admin]

  # A standard template should be organisationally visible. Funder templates that are 
  # meant for external use will be publicly visible. This allows a funder to create 'funder' as
  # well as organisational templates. The default template should also always be publicly_visible
  enum visibility: [:organisationally_visible, :publicly_visible]

  # defines the export setting for a template object
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end

  validates :org, :title, :version, presence: {message: _("can't be blank")}


# ---------------------------------------------------------
# NEW Scopes and methods for Template Versioning project
# ---------------------------------------------------------

  # Archiving scopes (should be used as base for all other scopes and queries!)
  # ---------------------------------------------------------
  scope :archived, -> { where(archived: true) }
  scope :unarchived, -> { where(archived: false) }

  # Version specific scopes
  # ---------------------------------------------------------
  scope :published, -> (family_id = nil) { 
    if family_id.present?
      unarchived.where(published: true, family_id: family_id)
    else
      unarchived.where(published: true) 
    end
  }
  
# Jose: I updated the relationships above so that we now have template.versions 
#       which ties to family_id; and customizations and customized_from which are
#       tied to customization_of.
#
#       We many be able to use those in many instances instead of these class
#       scopes
  scope :latest_version_numbers, -> (family_id = nil) {
    if family_id.present?
      unarchived.select("MAX(version) AS version", :family_id).where(family_id: family_ids).group(:family_id)
    else
      unarchived.select("MAX(version) AS version", :family_id).group(:family_id)
    end
  }
  scope :latest_version, -> (family_id = nil) {
    unarchived.from(latest_version_numbers(family_id), :current)
      .joins("INNER JOIN templates ON current.version = templates.version " +
             "AND current.family_id = templates.family_id").first
  }

  # Customization specific scopes
  # ---------------------------------------------------------
  scope :customization, -> (org_id = nil) { 
    if org_id.present?
      unarchived.latest.where(customization_of: self.id, org_id: org_id)
    else
      unarchived.latest.where(customization_of: self.id)
    end
  }
  scope :published_customization, -> (org_id) { 
    if org_id.present?
      published.customizations(org_id).where(published: true)
    end
  }

  # Org type specific scopes
  # ---------------------------------------------------------
  scope :public_funder, -> { 
    funder_ids = Org.funders.pluck(&:id)
    unarchived.latest
  }

  # Returns all of the unique family ids (unarchived)
  def self.family_ids
    Template.unarchived.pluck(&:family_id).uniq
  end
  
  # Returns a new version of this template
  def new_version
    if self.id.present?
      new_version = Template.deep_copy(self)
      new_version.version = (self.version + 1)
      new_version.published = false 
      new_version.visibility = self.visibility # do not change the visibility 
      new_version.is_default = self.is_default # retain the default template flag
      new_version
    else
      nil
    end
  end
  
# -----------------------------------------------------------------------------
# JOSE: The methods above are the ones I have been verifying and intend to keep. 
#       They each have corresponding unit tests (including a new one to check
#       for the proper default values for a new template).
#       The ones below are the old methods (e.g. 'valid'). If one of the old 
#       ones is still good and you think we should keep it, just move it up above
#       and adjust it if necessary.
#
#       
# -----------------------------------------------------------------------------




  scope :valid,  -> { where(archived: false) }
#  scope :published, -> { where(published: true) }

  # Retrieves all valid and published templates
  scope :valid_published, -> (is_default: false)  {
    Template.where(templates: { is_default: is_default }).unarchived.published()
  }

  scope :publicly_visible, -> { unarchived.where(:visibility => Template.visibilities[:publicly_visible]) }
  scope :organisationally_visible, -> { unarchived.where(:visibility => Template.visibilities[:organisationally_visible]) }
  
  # Retrieves template with distinct family_id that are valid (e.g. archived false) and customization_of is nil. Note,
  # if organisation ids are passed, the query will filter only those distinct family_ids for those organisations
  scope :families, -> (org_ids=nil) {
    if org_ids.is_a?(Array) 
      unarchived.where(org_id: org_ids, customization_of: nil).distinct
    else
      unarchived.where(customization_of: nil).distinct
    end 
  }
  # Retrieves the maximum version for the array of family_ids passed. If family_ids is missing, every maximum
  # version for each different family_id will be retrieved
  scope :family_ids_with_max_version, -> (family_ids=nil) {
    if family_ids.is_a?(Array)
      select("MAX(version) AS version", :family_id).unarchived.where(family_id: family_ids).group(:family_id)
    else
      select("MAX(version) AS version", :family_id).unarchived.group(:family_id)
    end
  }
  # Retrieves the maximum version for the array of customization_ofs passed. If customization_ofs is missing, every maximum
  # version for each different customization_of will be retrieved
  scope :customization_ofs_with_max_version, -> (customization_ofs=nil, org_id=nil) {
    chained_scope = select("MAX(version) AS version", :customization_of)
    if customization_ofs.respond_to?(:each)
      chained_scope = chained_scope.where(customization_of: customization_ofs)
    end
    if org_id.present?
      chained_scope = chained_scope.where(org_id: org_id)
    end
    chained_scope.group(:customization_of)
  }
  # Retrieves the latest template version, i.e. the one with maximum version for each family_id
  scope :latest_version, -> (family_ids=nil) {
    unarchived.from(family_ids_with_max_version(family_ids), :current)
    .joins("INNER JOIN templates ON current.version = templates.version"\
      " AND current.family_id = templates.family_id")
  }
  # Retrieves the latest customized version, i.e. the one with maximum version for each customization_of=dmptemplate_id
  scope :latest_customization, -> (org_id, family_ids=nil) {
    unarchived.from(customization_ofs_with_max_version(family_ids, org_id), :current)
    .joins("INNER JOIN templates ON current.version = templates.version"\
      " AND current.customization_of = templates.customization_of")
    .where('templates.org_id = ?', org_id)
  }
  
  scope :search, -> (term) {
    search_pattern = "%#{term}%"
    unarchived.joins(:org).where("templates.title LIKE ? OR orgs.name LIKE ?", search_pattern, search_pattern)
  }
  
  # Retrieves the list of all family_ids (template versioning families) for the specified Org
  def self.family_ids
    Template.unarchived.distinct.pluck(:family_id)
  end

  # Retrieves the most recent version of the template for the specified family_id
  def self.current(family_id)
    Template.unarchived.where(family_id: family_id).order(version: :desc).first
  end

  # Retrieves the current published version of the template for the specified Org and family_id
  def self.live(family_id)
    if family_id.respond_to?(:each)
      Template.unarchived.where(family_id: family_id, published: true)
    else
      Template.unarchived.where(family_id: family_id, published: true).first
    end
  end

  def self.default
    Template.unarchived.where(is_default: true, published: true).order(:version).last
  end

  ##
  # Retrieves the most current customization of the template for the
  # specified org and family_id
  # returns nil if no customizations found
  #
  # @params  family_ids of the original template
  # @params [integer] org_id for the customizing organisation
  # @return [nil, Template] the customized template or nil
  def self.org_customizations(family_ids, org_id)
    template_ids = latest_customization(org_id, family_ids).pluck(:id)
    unarchived.includes(:org).where(id: template_ids)
  end
  
  # Retrieves current templates with their org associated for a set of valid orgs
  # TODO pass an array of org ids instead of Org instances
  def self.get_latest_template_versions(orgs)
    if orgs.respond_to?(:each)
      families_ids = families(orgs.map(&:id)).pluck(:family_id)
    elsif orgs.is_a?(Org)
      families_ids = families([orgs.id]).pluck(:family_id)
    else
      families_ids = []
    end
    template_ids = latest_version(families_ids).pluck(:id)
    unarchived.includes(:org).where(id: template_ids)
  end
  
  # Retrieves current templates with their org associated for a set of valid orgs
  # TODO pass an array of org ids instead of Org instances
  def self.get_public_published_template_versions(orgs)
    if orgs.respond_to?(:each)
      families_ids = families(orgs.map(&:id)).pluck(:family_id)
    elsif orgs.is_a?(Org)
      families_ids = families([orgs.id]).pluck(:family_id)
    else
      families_ids = []
    end
    unarchived.includes(:org).where(family_id: families_ids, published: true, visibility: Template.visibilities[:publicly_visible])
  end
  
  ##
  # create a new version of the most current copy of the template
  #
  # @return [Template] new version
  def get_new_version
    if self.id.present?
      new_version = Template.deep_copy(self)
      new_version.version = (self.version + 1)
      new_version.published = false 
      new_version.visibility = self.visibility # do not change the visibility 
      new_version.is_default = self.is_default # retain the default template flag
      new_version.save!
      new_version
    else
      nil
    end
  end
  
  ##
  # deep copy the given template and all of it's associations
  #
  # @params [Template] template to be deep copied
  # @return [Template] saved copied template
  def self.deep_copy(template)
    template_copy = template.dup
    template_copy.save!
    template.phases.each do |phase|
      phase_copy = Phase.deep_copy(phase)
      phase_copy.template_id = template_copy.id
      phase_copy.save!
    end
    return template_copy
  end


  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?


  ##
  # convert the given template to a hash and return with all it's associations
  # to use, please pre-fetch org, phases, section, questions, annotations,
  #   question_options, question_formats,
  # TODO: Themes & guidance?
  #
  # @return [hash] hash of template, phases, sections, questions, question_options, annotations
  def to_hash
    hash = {}
    hash[:template] = {}
    hash[:template][:data] = self
    hash[:template][:org] = self.org
    phases = {}
    hash[:template][:phases] = phases
    self.phases.each do |phase|
      phases[phase.number] = {}
      phases[phase.number][:data] = phase
      phases[phase.number][:sections] = {}
      phase.sections.each do |section|
        phases[phase.number][:sections][section.number] = {}
        phases[phase.number][:sections][section.number][:data] = section
        phases[phase.number][:sections][section.number][:questions] = {}
        section.questions.each do |question|
          phases[phase.number][:sections][section.number][:questions][question.number] = {}
          phases[phase.number][:sections][section.number][:questions][question.number][:data] = question
          phases[phase.number][:sections][section.number][:questions][question.number][:annotations] = {}
          question.annotations.each do |annotation|
            phases[phase.number][:sections][section.number][:questions][question.number][:annotations][annotation.id] = {}
            phases[phase.number][:sections][section.number][:questions][question.number][:annotations][annotation.id][:data] = annotation
          end
          phases[phase.number][:sections][section.number][:questions][question.number][:question_options] = {}
          question.question_options.each do |question_option|
            phases[phase.number][:sections][section.number][:questions][question.number][:question_options][:data] = question_option
            phases[phase.number][:sections][section.number][:questions][question.number][:question_format] = question.question_format
          end
        end
      end
    end
    return hash
  end

# TODO: Why are we passing in an org and template here?
  ##
  # Verify if a template has customisation by given organisation
  #
  # @param org_id [integer] the integer id for an organisation
  # @param temp [family] a template object
  # @return [Boolean] true if temp has customisation by the given organisation
  def has_customisations?(org_id, temp)
    modifiable = true
    phases.each do |phase|
      modifiable = modifiable && phase.modifiable
    end
    return !modifiable
  end
  
  def template_type
    self.customization_of.present? ? _('customisation') : _('template')
  end

  # Retrieves the template's org or the org of the template this one is derived
  # from of it is a customization
  def base_org
    if self.customization_of.present?
      base_template_org = Template.where(dmptemplate_id: self.customization_of).first.org
    else
      base_template_org = self.org
    end
  end


# JOSE: I have already updated the creation defaults below but feel free to
# adjust if necessary
  # --------------------------------------------------------
  private
  # Initialize the new template
  def set_creation_defaults
    # Only run this before_validation because rails fires this before save/create
    if self.id.nil?
      self.published = false
      self.archived = false
      self.is_default = false if self.is_default.nil?
      self.version = 0 if self.version.nil?
      # Organisationally visible by default unless Org is only a funder
      self.visibility = (self.org.present? && self.org.funder_only?) ? Template.visibilities[:publicly_visible] : Template.visibilities[:organisationally_visible] 
      
      # Generate a unique identifier for the dmptemplate_id if necessary
      if self.family_id.nil?
        self.family_id = loop do
          random = rand 2147483647
          break random unless Template.exists?(family_id: random)
        end
      end
    end
  end
end
