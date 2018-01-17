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

  has_many :customizations, class_name: 'Template', foreign_key: 'dmptemplate_id'
  belongs_to :dmptemplate, class_name: 'Template'

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :id, :org_id, :description, :published, :title, :locale, :customization_of,
                  :is_default, :guidance_group_ids, :org, :plans, :phases, :dmptemplate_id,
                  :migrated, :version, :visibility, :published, :links, :as => [:default, :admin]

  # A standard template should be organisationally visible. Funder templates that are 
  # meant for external use will be publicly visible. This allows a funder to create 'funder' as
  # well as organisational templates. The default template should also always be publicly_visible
  enum visibility: [:organisationally_visible, :publicly_visible]

  # defines the export setting for a template object
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end

  validates :org, :title, :version, presence: {message: _("can't be blank")}

  scope :valid,  -> { where(migrated: false) }
  scope :published, -> { where(published: true) }

  # Retrieves all valid and published templates
  scope :valid_published, -> (is_default: false)  {
    Template.where(templates: { is_default: is_default }).valid().published()
  }

  scope :publicly_visible, -> { where(:visibility => Template.visibilities[:publicly_visible]).order(:title => :asc) }

  # Retrieves template with distinct dmptemplate_id that are valid (e.g. migrated false) and customization_of is nil. Note,
  # if organisation ids are passed, the query will filter only those distinct dmptemplate_ids for those organisations
  scope :families, -> (org_ids=nil) {
    if org_ids.is_a?(Array) 
      valid.where(org_id: org_ids, customization_of: nil).distinct
    else
      valid.where(customization_of: nil).distinct
    end 
  }
  # Retrieves the maximum version for the array of dmptemplate_ids passed. If dmptemplate_ids is missing, every maximum
  # version for each different dmptemplate_id will be retrieved
  scope :dmptemplate_ids_with_max_version, -> (dmptemplate_ids=nil) {
    if dmptemplate_ids.is_a?(Array)
      select("MAX(version) AS version", :dmptemplate_id).where(dmptemplate_id: dmptemplate_ids).group(:dmptemplate_id)
    else
      select("MAX(version) AS version", :dmptemplate_id).group(:dmptemplate_id)
    end
  }
  # Retrieves the maximum version for the array of customization_ofs passed. If customization_ofs is missing, every maximum
  # version for each different customization_of will be retrieved
  scope :customization_ofs_with_max_version, -> (customization_ofs=nil) {
    if customization_ofs.is_a?(Array)
      select("MAX(version) AS version", :customization_of).where(customization_of: customization_ofs).group(:customization_of)
    else
      select("MAX(version) AS version", :customization_of).group(:customization_of)
    end
  }
  # Retrieves the latest template version, i.e. the one with maximum version for each dmptemplate_id
  scope :latest_version, -> (dmptemplate_ids=nil) {
    from(dmptemplate_ids_with_max_version(dmptemplate_ids), :current)
    .joins("INNER JOIN templates ON current.version = templates.version"\
      " AND current.dmptemplate_id = templates.dmptemplate_id")
  }
  # Retrieves the latest customized version, i.e. the one with maximum version for each customization_of=dmptemplate_id
  scope :latest_customization, -> (org_id, dmptemplate_ids=nil) {
    from(customization_ofs_with_max_version(dmptemplate_ids), :current)
    .joins("INNER JOIN templates ON current.version = templates.version"\
      " AND current.customization_of = templates.customization_of")
    .where('templates.org_id = ?', org_id)
  }
  
  scope :search, -> (term) {
    search_pattern = "%#{term}%"
    joins(:org).where("templates.title LIKE ? OR orgs.name LIKE ?", search_pattern, search_pattern)
  }
  
  # Retrieves the list of all dmptemplate_ids (template versioning families) for the specified Org
  def self.dmptemplate_ids
    Template.all.valid.distinct.pluck(:dmptemplate_id)
  end

  # Retrieves the most recent version of the template for the specified Org and dmptemplate_id
  def self.current(dmptemplate_id)
    Template.where(dmptemplate_id: dmptemplate_id).order(version: :desc).valid.first
  end

  # Retrieves the current published version of the template for the specified Org and dmptemplate_id
  def self.live(dmptemplate_id)
    if dmptemplate_id.respond_to?(:each)
      Template.where(dmptemplate_id: dmptemplate_id, published: true).valid
    else
      Template.where(dmptemplate_id: dmptemplate_id, published: true).valid.first
    end
  end

  def self.default
    Template.valid.where(is_default: true, published: true).order(:version).last
  end

  ##
  # Retrieves the most current customization of the template for the
  # specified org and dmptemplate_id
  # returns nil if no customizations found
  #
  # @params  dmptemplate_ids of the original template
  # @params [integer] org_id for the customizing organisation
  # @return [nil, Template] the customized template or nil
  def self.org_customizations(dmptemplate_ids, org_id)
    template_ids = latest_customization(org_id, dmptemplate_ids).pluck(:id)
    includes(:org).where(id: template_ids)
  end
  
  # Retrieves current templates with their org associated for a set of valid orgs
  # TODO pass an array of org ids instead of Org instances
  def self.get_latest_template_versions(orgs)
    if orgs.respond_to?(:each)
      families_ids = families(orgs.map(&:id)).pluck(:dmptemplate_id)
    elsif orgs.is_a?(Org)
      families_ids = families([orgs.id]).pluck(:dmptemplate_id)
    else
      families_ids = []
    end
    template_ids = latest_version(families_ids).pluck(:id)
    includes(:org).where(id: template_ids)
  end
  
  # Retrieves current templates with their org associated for a set of valid orgs
  # TODO pass an array of org ids instead of Org instances
  def self.get_public_published_template_versions(orgs)
    if orgs.respond_to?(:each)
      families_ids = families(orgs.map(&:id)).pluck(:dmptemplate_id)
    elsif orgs.is_a?(Org)
      families_ids = families([orgs.id]).pluck(:dmptemplate_id)
    else
      families_ids = []
    end
    includes(:org).where(dmptemplate_id: families_ids, published: true, visibility: Template.visibilities[:publicly_visible])
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
  # @param temp [dmptemplate] a template object
  # @return [Boolean] true if temp has customisation by the given organisation
  def has_customisations?(org_id, temp)
    modifiable = true
    phases.each do |phase|
      modifiable = modifiable && phase.modifiable
    end
    return !modifiable
  end

  # --------------------------------------------------------
  private
  # Initialize the published and dirty flags for new templates
  def set_creation_defaults
    # Only run this before_validation because rails fires this before save/create
    if self.id.nil?
      self.published = false
      self.migrated = false
      self.dirty = false
      self.visibility = 1
      self.is_default = false
      self.version = 0 if self.version.nil?
      self.visibility = Template.visibilities[:organisationally_visible] if self.visibility.nil?

      # Generate a unique identifier for the dmptemplate_id if necessary
      if self.dmptemplate_id.nil?
        self.dmptemplate_id = loop do
          random = rand 2147483647
          break random unless Template.exists?(dmptemplate_id: random)
        end
      end
    end
  end

end
