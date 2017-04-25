class Template < ActiveRecord::Base
  include GlobalHelpers

  before_create :set_creation_defaults
  after_create  :set_modifiable_statuses
  
  before_save   :pre_publishing
  after_save    :post_publishing

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
  attr_accessible :id, :org_id, :description, :published, :title, :locale, 
                  :is_default, :guidance_group_ids, :org, :plans, :phases, :dmptemplate_id,
                  :version, :visibility, :published, :as => [:default, :admin]

  # defines the export setting for a template object
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end

  validates :org, :title, :version, presence: {message: _("can't be blank")}

  # Retrieves the list of all dmptemplate_ids (template versioning families) for the specified Org
  def self.dmptemplate_ids(org)
    Template.where(org_id: org.id).distinct.pluck(:dmptemplate_id)
  end

  # Retrieves the most recent version of the template for the specified Org and dmptemplate_id 
  def self.current(org, dmptemplate_id)
    Template.where(dmptemplate_id: dmptemplate_id, org_id: org.id).order(version: :desc).first
  end
  
  # Retrieves the current published version of the template for the specified Org and dmptemplate_id  
  def self.live(org, dmptemplate_id)
    Template.where(dmptemplate_id: dmptemplate_id, org_id: org.id, published: true).first
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
  # to use, please pre-fetch org, phases, section, questions, suggested_answers, 
  #   question_options, question_formats, 
  # TODO: Themes & guidance?
  #
  # @return [hash] hash of template, phases, sections, questions, question_options, suggested_answers
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
          phases[phase.number][:sections][section.number][:questions][question.number][:suggested_answers] = {}
          question.suggested_answers.each do |suggested_answer|
            phases[phase.number][:sections][section.number][:questions][question.number][:suggested_answers][suggested_answer.id] = {}
            phases[phase.number][:sections][section.number][:questions][question.number][:suggested_answers][suggested_answer.id][:data] = suggested_answer
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
    self.published = false
    self.dirty = false
    
    # Generate a unique identifier for the dmptemplate_id if necessary
    if self.dmptemplate_id.nil?
      self.dmptemplate_id = loop do
        random = rand 2147483647
        break random unless Template.exists?(dmptemplate_id: random)
      end
    end
  end
  
  # Unpublish older versions when publishing the template
  def pre_publishing
    if self.published?
      # Unpublish the older published version if there is one
      live = Template.live(self.org, self.dmptemplate_id)
      if !live.nil? and self != live
        live.published = false
        live.save!
      end
      # Set the dirty flag to false
      self.dirty = false
    end
  end
  
  # Once the version has been published, create a new one which should
  # be returned by the Template.current method
  def post_publishing
    # Create a new version 
    new_version = Template.deep_copy(self)
    new_version.version = (self.version + 1)
    new_version.save
  end

  # Update the modifiable flags on phases->sections->questions 
  def set_modifiable_statuses
    # If we're working with a customization and its version 0 
    # we should mark all of the phases->sections->questions 
    # as unmodifiable
    if !self.customization_of.nil? && version == 0
      self.phases.includes(:sections, :questions).each do |phase|
        phase.modifiable = false
        phase.save!
        phase.sections.each do |section|
          section.modifiable = false
          section.save!
          section.questions.each do |question|
            question.modifiable = false
            question.save!
          end
        end
      end
    end
  end

end
