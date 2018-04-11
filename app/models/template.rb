class Template < ActiveRecord::Base
  include GlobalHelpers
  include ActiveModel::Validations
  include TemplateScope
  validates_with TemplateLinksValidator

  before_create :set_creation_defaults 

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
  def deep_copy(modifiable=true)
    copy = self.dup
    copy.phases = self.phases.map{ |phase| phase.deep_copy(modifiable) }
    return copy
  end

  # Returns whether or not this is the latest version of the current template's family
  def is_latest?
    return (self.id == Template.latest_version(self.family_id).pluck(:id).first)
  end

  # Returns a new unpublished copy of this template (with a version number incremented by 1)
  def new_version(modifiable=true)
    new_version = self.deep_copy(modifiable)
    new_version.version = (self.version + 1)
    new_version.published = false 
    new_version.visibility = self.visibility # do not change the visibility 
    new_version.is_default = self.is_default # retain the default template flag
    return new_version
  end

  # Returns a new copy of this template that is ready for customization by the specified org
  def customize(customizing_org)
    customization = self.deep_copy(false) # Set modifiable=false for all phases/sections/questions of original template
    customization.family_id = new_family_id
    customization.customization_of = self.family_id
    customization.version = 0
    customization.org = customizing_org
    customization.published = false
    customization.visibility = Template.visibilities[:organisationally_visible] # Customizers are never funder_only Orgs
    customization.is_default = false

    # Set the modifiable flag on all of the templates components to false
    customization.phases.each do |phase|
      phase.modifiable = false
      phase.sections.each do |section|
        section.modifiable = false
        section.questions.each do |question|
          question.modifiable = false
        end
      end
    end
    return customization
  end

  def upgrade_customization
    # Retrieve the latest published copy of the parent template then create the new customization
    origin = Template.published(self.customization_of)
    target = origin.customize(self.org)
    
    # Copy over all of the existing annotations from the current customization if they can be matched to questions on the new one
    # TODO: Is there a better way to do this than match on the number without modifying the DB? 
    target.phases.each do |phase|
      original_phase = self.phases.joins(sections: :questions).includes(sections: :questions).select{ |p| p.number == phase.number }
      if original_phase.present?
        phase.sections.each do |section|
          original_section = original_phase.sections.select{ |s| s.number == section.number }
          if original_section.present?
            section.questions.each do |question|
              original_question = original_section.questions.select{ |q| q.number == question.number }
              if original_question.present?
                original_question.annotations.where(org_id: self.org.id).each do |annotation|
                  question.annotations << annotation.deep_copy
                end
              end
            end # questions.each
          end
        end # sections.each
      end
    end
    
    # Copy over any entirely new sections
    self.phases.includes(:phase, { sections: :questions }).where('sections.modifiable = ?', true).each do |section|
      new_phase = target.phases.select{ |p| p.number == section.phase.number }
      new_phase.sections << section.deep_copy if new_phase.present?
    end
    target
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
  
  # Initialize the new template
  def set_creation_defaults
    # Only run this before_validation because rails fires this before save/create
    if self.id.nil?
      self.published = false
      self.archived = false
      self.version = 0 if self.version.nil?
      self.is_default = false if self.is_default.nil?
      self.family_id = new_family_id if self.family_id.nil?
      # Organisationally visible by default unless Org is only a funder
      self.visibility = (self.org.present? && self.org.funder_only?) ? Template.visibilities[:publicly_visible] : Template.visibilities[:organisationally_visible] 
    end
  end
end
