class Template < ActiveRecord::Base
  include GlobalHelpers
  include ActiveModel::Validations
  include TemplateScope
  validates_with TemplateLinksValidator

  before_validation :set_defaults 
  after_update :reconcile_published, if: Proc.new { |template| template.published? }

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
    def find_or_generate_version!(template)
      if template.latest?
        if template.generate_version?
          return template.generate_version!
        end
        return template
      end
      raise _('A historical template cannot be retrieved for being modified')
    end
  end

  # Creates a copy of the current template
  # raises ActiveRecord::RecordInvalid when save option is true and validations fails
  def deep_copy(attributes: {}, **options)
    copy = self.dup
    if attributes.respond_to?(:each_pair)
      attributes.each_pair{ |attribute, value| copy.send("#{attribute}=".to_sym, value) if copy.respond_to?("#{attribute}=".to_sym) }
    end
    copy.save! if options.fetch(:save, false)
    options[:template_id] = copy.id
    self.phases.each{ |phase| copy.phases << phase.deep_copy(options) }
    return copy
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

  # Returns whether or not this is the latest version of the current template's family
  def latest?
    return (self.id == Template.latest_version(self.family_id).pluck(:id).first)
  end
  # Determines whether or not a new version should be generated
  def generate_version?
    return self.published
  end
  # Determines whether or not a customization for the customizing_org passed should be generated
  def customize?(customizing_org)
    if customizing_org.is_a?(Org) && (self.org.funder_only? || self.is_default)
      return !Template.unarchived.where(customization_of: self.family_id, org: customizing_org).exists?
    end
    return false
  end
  # Determines whether or not a customized template should be upgraded
  def upgrade_customization?
    if self.customization_of.present?
      funder_template = Template.published(self.customization_of).select(:created_at).first
      if funder_template.present?
        return funder_template.created_at > self.created_at
      end
    end
    return false
  end

  # Checks to see if the template family has a published version and if its not the current template
  def draft?
    return !self.published && Template.published(self.family_id).length > 0
  end

  def removable?
    versions = Template.includes(:plans).where(family_id: self.family_id)
    return versions.select{|version| version.plans.length > 0 }.empty?
  end

  # Returns a new unpublished copy of self with a new family_id, version = zero for the specified org
  def generate_copy!(org)
    raise _('generate_copy! requires an organisation target') unless org.is_a?(Org) # Assume customizing_org is persisted
    template = deep_copy(
      attributes: {
        version: 0,
        published: false,
        family_id: new_family_id,
        org: org,
        is_default: false,
        title: _('Copy of %{template}') % { template: self.title }
      }, modifiable: true, save: true)
    return template
  end

  # Generates a new copy of self with an incremented version number
  def generate_version!
    raise _('generate_version! requires a published template') unless published
    template = deep_copy(
      attributes: {
        version: self.version+1,
        published: false,
        org: self.org
      }, save: true)
    return template
  end

  # Generates a new copy of self for the specified customizing_org
  def customize!(customizing_org)
    raise _('customize! requires an organisation target') unless customizing_org.is_a?(Org) # Assume customizing_org is persisted
    raise _('customize! requires a template from a funder') if !self.org.funder_only? && !self.is_default # Assume self has org associated
    customization = deep_copy(
      attributes: {
        version: 0,
        published: false,
        family_id: new_family_id,
        customization_of: self.family_id,
        org: customizing_org,
        visibility: Template.visibilities[:organisationally_visible],
        is_default: false
      }, modifiable: false, save: true)
    return customization
  end
  
  # Generates a new copy of self including latest changes from the funder this template is customized_of
  def upgrade_customization!
    raise _('upgrade_customization! requires a customised template') unless customization_of.present?
    funder_template = Template.published(self.customization_of).first
    raise _('upgrade_customization! cannot be carried out since there is no published template of its current funder') unless funder_template.present?
    source = deep_copy(attributes: { version: self.version+1, published: false }) # preserves modifiable flags from the self template copied
    # Creates a new customisation for the published template whose family_id is self.customization_of
    customization = funder_template.deep_copy(
      attributes: {
        version: source.version,
        published: source.published,
        family_id: source.family_id,
        customization_of: source.customization_of,
        org: source.org,
        visibility: Template.visibilities[:organisationally_visible],
        is_default: false
      }, modifiable: false, save: true)
    # Sorts the phases from the source template, i.e. self
    sorted_phases = source.phases.sort{ |phase1,phase2| phase1.number <=> phase2.number }
    # Merges modifiable sections or questions from source into customization template object
    customization.phases.each do |customization_phase|
      # Search for the phase in the source template whose number matches the customization_phase
      candidate_phase = sorted_phases.bsearch{ |phase| customization_phase.number <=> phase.number }
      if candidate_phase.present? # The funder could have added this new phase after the customisation took place
        # Selects modifiable sections from the candidate_phase
        modifiable_sections = candidate_phase.sections.select{ |section| section.modifiable }
        # Attaches modifiable sections into the customization_phase
        modifiable_sections.each{ |modifiable_section| customization_phase.sections << modifiable_section }
        # Sorts the sections for the customization_phase
        sorted_sections = customization_phase.sections.sort{ |section1, section2| section1.number <=> section2.number }
        # Selects unmodifiable sections from the candidate_phase
        unmodifiable_sections = candidate_phase.sections.select{ |section| !section.modifiable }
        unmodifiable_sections.each do |unmodifiable_section|
          # Search for modifiable questions within the unmodifiable_section from candidate_phase
          modifiable_questions = unmodifiable_section.questions.select{ |question| question.modifiable }
          customization_section = sorted_sections.bsearch{ |section| unmodifiable_section.number <=> section.number }
          if customization_section.present? # The funder could have deleted the section
            modifiable_questions.each{ |modifiable_question| customization_section.questions << modifiable_question; }
          end
          # Search for unmodifiable questions within the unmodifiable_section in case source template added annotations
          unmodifiable_questions = unmodifiable_section.questions.select{ |question| !question.modifiable }
          sorted_questions = customization_section.questions.sort{ |question1, question2| question1.number <=> question2.number }
          unmodifiable_questions.each do |unmodifiable_question|
            customization_question = sorted_questions.bsearch{ |question| unmodifiable_question.number <=> question.number }
            if customization_question.present?  # The funder could have deleted the question
              annotations_added_by_customiser = unmodifiable_question.annotations.select{ |annotation| annotation.org_id == source.org_id }
              annotations_added_by_customiser.each{ |annotation| customization_question.annotations << annotation }
            end
          end
        end
      end
    end
    # Appends the modifiable phases from source
    source.phases.select{ |phase| phase.modifiable }.each{ |modifiable_phase| customization.phases << modifiable_phase }
    return customization
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
      self.visibility = ((self.org.present? && self.org.funder_only?) || self.is_default?) ? Template.visibilities[:publicly_visible] : Template.visibilities[:organisationally_visible] unless self.id.present?
      self.customization_of ||= nil
      self.family_id ||= new_family_id
      self.archived ||= false
      self.links ||= { funder: [], sample_plan: [] }
    end
    
    # Only one version of a template should be published at a time, so if this one was published make sure other versions are not
    def reconcile_published
      # Unpublish all other versions of this template family
      Template.where('family_id = ? AND published = ? AND id != ?', self.family_id, true, self.id).update_all(published: false)
    end
end
