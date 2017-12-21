class Template < ActiveRecord::Base
  include GlobalHelpers

  before_validation :set_creation_defaults
  scope :valid,  -> {where(migrated: false)}
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
                  :migrated, :version, :visibility, :published, :as => [:default, :admin]

  # defines the export setting for a template object
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end

  validates :org, :title, :version, presence: {message: _("can't be blank")}

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
    Template.where(dmptemplate_id: dmptemplate_id, published: true).valid.first
  end

  def self.default
    Template.valid.where(is_default: true, published: true).order(:version).last
  end

  ##
  # Retrieves the most current customization of the template for the
  # specified org and dmptemplate_id
  # returns nil if no customizations found
  #
  # @params [integer] dmptemplate_id of the original template
  # @params [integer] org_id for the customizing organisation
  # @return [nil, Template] the customized template or nil
  def self.org_customizations(dmptemplate_id, org_id)
    Template.where(customization_of: dmptemplate_id, org_id: org_id).order(version: :desc).valid.first
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
