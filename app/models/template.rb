class Template < ActiveRecord::Base
  include GlobalHelpers
  include ActiveModel::Validations
  include TemplateScope
  validates_with TemplateLinksValidator

  before_validation :set_defaults 

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

  validates :org, :title, presence: {message: _("can't be blank")}

  # Class methods gets defined within this 
  class << self
    def current(family_id)
      unarchived.where(family_id: family_id).order(version: :desc).first
    end
    def live(family_id)
      if family_id.respond_to?(:each)
        unarchived.where(family_id: family_id, published: true)
      else
        unarchived.where(family_id: family_id, published: true).first
      end
    end
    def default
      unarchived.where(is_default: true, published: true).order(:version).last
    end
  end

  # Creates a copy of the current template
  def deep_copy(**options)
    copy = self.dup
    copy.version = options.fetch(:version, self.version)
    copy.published = options.fetch(:published, self.published)
    copy.phases = self.phases.map{ |phase| phase.deep_copy(options) }
    return copy
  end

  # Returns whether or not this is the latest version of the current template's family
  def is_latest?
    return (self.id == Template.latest_version(self.family_id).pluck(:id).first)
  end

  # Generates a new copy of self
  def generate_version
    raise _('generate_version requires a published template') unless published
    raise _('generate_version is only applicable for a non-customised template. Use customize instead') if customization_of.present?
    template = deep_copy(version: self.version+1, published: false)
    return template
  end

  # Generates a new copy of self for the specified customizing_org
  def customize(customizing_org)
    raise _('customize requires an organisation target') unless customizing_org.is_a?(Org) # Assume customizing_org is persisted
    raise _('customize requires a template from a funder') unless org.funder_only? # Assume self has org associated
    customization = deep_copy(modifiable: false, version: 0, published: false)
    customization.family_id = new_family_id
    customization.customization_of = family_id
    customization.org = customizing_org
    customization.visibility = Template.visibilities[:organisationally_visible]
    customization.is_default = false
    return customization
  end

  def upgrade_customization
    raise _('upgrade_customization requires a customised template') unless customization_of.present?
    target = self
    if self.published?
      target = deep_copy(version: self.version+1, published: false) # preserves modifiable flags from the self template copied
    end
    # Creates a new customisation for the published template whose family_id is self.customization_of
    customization = Template.published(self.customization_of).first.customize(self.org)

    # Merges modifiable sections or questions from target into customization template object
    customization.phases = customization.phases.map do |customization_phase|
      # Search for the phase in target whose number is equal
      candidate_phase_index = target.phases.find_index{ |phase| phase.number == customization_phase.number }
      # Selects modifiable sections from the candidate_phase
      modifiable_sections = target.phases[candidate_phase_index].sections.select{ |section| section.modifiable }
      # Attaches modifiable sections into the customization_phase
      modifiable_sections.each do |modifiable_section|
        customization_phase.sections << modifiable_section
      end
      # Selects unmodifiable sections from the candidate_phase
      unmodifiable_sections = target.phases[candidate_phase_index].sections.select{ |section| !section.modifiable }
      unmodifiable_sections.each do |unmodifiable_section|
        # Search for modifiable questions within the target template
        modifiable_questions = unmodifiable_section.questions.select{ |question| question.modifiable }
        customization_section_index = customization_phase.sections.find_index{ |section| section.number == unmodifiable_section.number }
        modifiable_questions.each do |modifiable_question|
          customization_phase.sections[customization_section_index] << modifiable_question
        end
      end
    end
    # Appends the modifiable phases from target
    target.phases.select{ |phase| phase.modifiable }.each do |modifiable_phase|
      customization.phases << modifiable_phase
    end
    
    # Update the upgraded customization's version number
    customization.version = target.version

    return customization
  end

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

  # TODO: Determine if this should be in the controller/views instead of the model
  def template_type
    self.customization_of.present? ? _('customisation') : _('template')
  end

  # Retrieves the template's org or the org of the template this one is derived
  # from of it is a customization
  def base_org
    if self.customization_of.present?
      return Template.where(family_id: self.customization_of).first.org
    else
      return self.org
    end
  end

  private
  # Generate a new random family identifier
  def new_family_id
    family_id = loop do
      random = rand 2147483647
      break random unless Template.exists?(family_id: random)
    end
    family_id
  end
  # Default values to set before running any validation
  def set_defaults
    self.published ||= false
    self.archived ||= false
    self.is_default ||= false
    self.version ||= 0
    self.visibility = (org.present? && org.funder_only?) ? Template.visibilities[:publicly_visible] : Template.visibilities[:organisationally_visible]
    self.customization_of ||= nil
    self.family_id ||= new_family_id
    self.archived ||= false
    self.links ||= { funder: [], sample_plan: [] }
  end
end
