class Template < ActiveRecord::Base
  include GlobalHelpers
  include ActiveModel::Validations
  include TemplateScope
  validates_with TemplateLinksValidator

  before_validation :set_creation_defaults # TODO use before_create instead?

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
  has_many :customizations, class_name: 'Template', foreign_key: 'customization_of' # This will return empty list unless customization_of values are ids from templates.id
  belongs_to :customized_from, class_name: 'Template' # This requires adding new attribute to the table (e.g. customized_from) and its value MUST be an id from templates.id

  # Self join for Siblings/Versions. This will return nil unless family_id is an id from templates.id attribute
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
    # TODO re-implementation with set of options and no side-effects, i.e. never save
    def deep_copy(template)
      template_copy = template.dup
      template_copy.save!
      template.phases.each do |phase|
        phase_copy = Phase.deep_copy(phase)
        phase_copy.template_id = template_copy.id
        phase_copy.save!
      end
      return template_copy
    end
  end

  def deep_copy(modifiable=true)
    copy = self.dup
    copy.phases = self.phases.map{ |phase| phase.deep_copy(modifiable) }
    return copy
  end

  # Returns a new version of this template
  # TODO thread-safe, we need to lock the specific template to increment the versioning
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
  ##
  # create a new version of the most current copy of the template
  #
  # @return [Template] new version
  # TODO remove? it is very similar to template#new_version
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
