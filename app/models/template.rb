# == Schema Information
#
# Table name: templates
#
#  id               :integer          not null, primary key
#  archived         :boolean
#  customization_of :integer
#  description      :text
#  is_default       :boolean
#  links            :text
#  locale           :string
#  published        :boolean
#  title            :string
#  version          :integer
#  visibility       :integer
#  created_at       :datetime
#  updated_at       :datetime
#  family_id        :integer
#  org_id           :integer
#
# Indexes
#
#  index_templates_on_customization_of_and_version_and_org_id  (customization_of,version,org_id) UNIQUE
#  index_templates_on_family_id                                (family_id)
#  index_templates_on_family_id_and_version                    (family_id,version) UNIQUE
#  index_templates_on_org_id                                   (org_id)
#  template_organisation_dmptemplate_index                     (org_id,family_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#

class Template < ActiveRecord::Base
  include GlobalHelpers
  include ValidationMessages
  include ValidationValues

  validates_with TemplateLinksValidator


  # Stores links as an JSON object:
  # {funder: [{"link":"www.example.com","text":"foo"}, ...],
  #  sample_plan: [{"link":"www.example.com","text":"foo"}, ...]}
  #
  # The links is validated against custom validator allocated at
  # validators/template_links_validator.rb
  serialize :links, JSON

  # ================
  # = Associations =
  # ================

  belongs_to :org

  has_many :plans

  has_many :phases, dependent: :destroy

  has_many :sections, through: :phases

  has_many :questions, through: :sections

  has_many :annotations, through: :questions

  # ===============
  # = Validations =
  # ===============

  validates :title, presence: { message: PRESENCE_MESSAGE }

  validates :org, presence: { message: PRESENCE_MESSAGE }

  validates :locale, presence: { message: PRESENCE_MESSAGE }

  validates :version, presence: { message: PRESENCE_MESSAGE },
                      uniqueness: { message: UNIQUENESS_MESSAGE,
                                    scope: :family_id }

  validates :visibility, presence: { message: PRESENCE_MESSAGE }

  validates :family_id, presence: { message: PRESENCE_MESSAGE }


  # =============
  # = Callbacks =
  # =============

  before_validation :set_defaults

  after_update :reconcile_published, if: -> (template) { template.published? }


  # ==========
  # = Scopes =
  # ==========

  scope :archived, -> { where(archived: true) }

  scope :unarchived, -> { where(archived: false) }

  scope :published, ->(family_id = nil) {
    if family_id.present?
      unarchived.where(published: true, family_id: family_id)
    else
      unarchived.where(published: true)
    end
  }

  # Retrieves the latest templates, i.e. those with maximum version associated.
  # It can be filtered down if family_id is passed
  scope :latest_version, ->(family_id = nil) {
    unarchived.from(latest_version_per_family(family_id), :current)
              .joins(<<~SQL)
                INNER JOIN templates ON current.version = templates.version
                  AND current.family_id = templates.family_id
                INNER JOIN orgs ON orgs.id = templates.org_id
              SQL
  }

  # Retrieves the latest customized versions, i.e. those with maximum version
  # associated for a set of family_id and an org
  scope :latest_customized_version, ->(family_id = nil, org_id = nil) {
    unarchived
      .from(latest_customized_version_per_customised_of(family_id, org_id),
            :current)
      .joins(<<~SQL)
        INNER JOIN templates ON current.version = templates.version
          AND current.customization_of = templates.customization_of
        INNER JOIN orgs ON orgs.id = templates.org_id
      SQL
      .where(templates: { org_id: org_id })
  }

  # Retrieves the latest templates, i.e. those with maximum version associated
  # for a set of org_id passed
  scope :latest_version_per_org, ->(org_id = nil) {
    family_ids = if org_id.respond_to?(:each)
                   families(org_id).pluck(:family_id)
                 else
                   families([org_id]).pluck(:family_id)
                 end
    latest_version(family_ids)
  }

  # Retrieve all of the latest customizations for the specified org
  scope :latest_customized_version_per_org, lambda { |org_id = nil|
    family_ids = families(org_id).pluck(:family_id)
    latest_customized_version(family_ids, org_id)
  }

  # Retrieves templates with distinct family_id. It can be filtered down if
  # org_id is passed
  scope :families, lambda { |org_id = nil|
    if org_id.respond_to?(:each)
      unarchived.where(org_id: org_id, customization_of: nil).distinct
    else
      unarchived.where(customization_of: nil).distinct
    end
  }

  # Retrieves the latest version of each customizable funder template (and the
  # default template)
  scope :latest_customizable, lambda {
    funder_ids = Org.funder.pluck(:id)
    family_ids = families(funder_ids).distinct
                                     .pluck(:family_id) + [default.family_id]

    published(family_ids.flatten)
      .where('visibility = :visibility OR is_default = :is_default',
             visibility: visibilities[:publicly_visible], is_default: true)
  }

  # Retrieves unarchived templates with public visibility
  scope :publicly_visible, lambda {
    unarchived.where(visibility: visibilities[:publicly_visible])
  }

  # Retrieves unarchived templates with organisational visibility
  scope :organisationally_visible, lambda {
    unarchived.where(visibility: visibilities[:organisationally_visible])
  }

  # Retrieves unarchived templates whose title or org.name includes the term
  # passed
  scope :search, lambda { |term|
    unarchived.where("templates.title LIKE :term OR orgs.name LIKE :term",
                     term: "%#{term}%")
  }

  # A standard template should be organisationally visible. Funder templates
  # that are meant for external use will be publicly visible. This allows a
  # funder to create 'funder' as well as organisational templates. The default
  # template should also always be publicly_visible.
  enum visibility: %i[organisationally_visible publicly_visible]

  # defines the export setting for a template object
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end

  validates :org, :title, presence: { message: _("can't be blank") }

  # =================
  # = Class Methods =
  # =================

  def self.default
    where(is_default: true, published: true).last
  end

  def self.current(family_id)
    unarchived.where(family_id: family_id).order(version: :desc).first
  end

  def self.live(family_id)
    if family_id.respond_to?(:each)
      unarchived.where(family_id: family_id, published: true)
    else
      unarchived.where(family_id: family_id, published: true).first
    end
  end

  def self.find_or_generate_version!(template)
    if template.latest? && template.generate_version?
      template.generate_version!
    elsif template.latest? && !template.generate_version?
      template
    else
      raise _('A historical template cannot be retrieved for being modified')
    end
  end

  # Retrieves the latest templates, i.e. those with maximum version associated.
  # It can be filtered down if family_id is passed. NOTE, the template objects
  # instantiated only contain version and family attributes populated. See
  # Template::latest_version scope method for an adequate instantiation of
  # template instances.
  def self.latest_version_per_family(family_id = nil)
    chained_scope = unarchived.select("MAX(version) AS version", :family_id)
    if family_id.present?
      chained_scope = chained_scope.where(family_id: family_id)
    end
    chained_scope.group(:family_id)
  end

  private_class_method :latest_version_per_family

  def self.latest_customized_version_per_customised_of(customization_of = nil,
                                                       org_id = nil)
    chained_scope = select("MAX(version) AS version", :customization_of)
    chained_scope = chained_scope.where(customization_of: customization_of)
    chained_scope = chained_scope.where(org_id: org_id) if org_id.present?
    chained_scope.group(:customization_of)
  end

  private_class_method :latest_customized_version_per_customised_of


  # ===========================
  # = Public instance methods =
  # ===========================

  # Creates a copy of the current template
  # raises ActiveRecord::RecordInvalid when save option is true and validations
  # fails.
  def deep_copy(attributes: {}, **options)
    copy = dup
    if attributes.respond_to?(:each_pair)
      attributes.each_pair do |attribute, value|
        if copy.respond_to?("#{attribute}=".to_sym)
          copy.send("#{attribute}=".to_sym, value)
        end
      end
    end
    copy.save! if options.fetch(:save, false)
    options[:template_id] = copy.id
    phases.each { |phase| copy.phases << phase.deep_copy(options) }
    copy
  end

  # Retrieves the template's org or the org of the template this one is derived
  # from of it is a customization
  def base_org
    if customization_of.present?
      Template.where(family_id: customization_of).first.org
    else
      org
    end
  end

  # Returns whether or not this is the latest version of the current template's
  # family
  def latest?
    id == Template.latest_version(family_id).pluck(:id).first
  end

  # Determines whether or not a new version should be generated
  def generate_version?
    published
  end

  # Determines whether or not a customization for the customizing_org passed
  # should be generated
  def customize?(customizing_org)
    if customizing_org.is_a?(Org) && (org.funder_only? || is_default)
      return !Template.unarchived.where(customization_of: family_id,
                                        org: customizing_org).exists?
    end
    false
  end

  # Determines whether or not a customized template should be upgraded
  def upgrade_customization?
    if customization_of.present?
      funder_template = Template.published(customization_of)
                                .select(:created_at).first

      return funder_template.created_at > created_at if funder_template.present?
    end
    false
  end

  # Checks to see if the template family has a published version and if its not
  # the current template
  def draft?
    !published && !Template.published(family_id).empty?
  end

  def removable?
    versions = Template.includes(:plans).where(family_id: family_id)
    versions.reject { |version| version.plans.empty? }.empty?
  end

  # Returns a new unpublished copy of self with a new family_id, version = zero
  # for the specified org
  def generate_copy!(org)
    raise _('generate_copy! requires an organisation target') unless org.is_a?(Org) # Assume customizing_org is persisted
    template = deep_copy(
      attributes: {
        version: 0,
        published: false,
        family_id: new_family_id,
        org: org,
        is_default: false,
        title: format(_('Copy of %{template}'), template: title)
      }, modifiable: true, save: true
    )
    template
  end

  # Generates a new copy of self with an incremented version number
  def generate_version!
    raise _('generate_version! requires a published template') unless published
    template = deep_copy(
      attributes: {
        version: version + 1,
        published: false,
        org: org
      }, save: true
    )
    template
  end

  # Generates a new copy of self for the specified customizing_org
  def customize!(customizing_org)
    # Assume customizing_org is persisted
    unless customizing_org.is_a?(Org)
      raise _('customize! requires an organisation target')
    end

    # Assume self has org associated
    if !org.funder_only? && !is_default
      raise _('customize! requires a template from a funder')
    end

    customization = deep_copy(
      attributes: {
        version: 0,
        published: false,
        family_id: new_family_id,
        customization_of: family_id,
        org: customizing_org,
        visibility: Template.visibilities[:organisationally_visible],
        is_default: false
      }, modifiable: false, save: true
    )
    customization
  end

  # Generates a new copy of self including latest changes from the funder this
  # template is customized_of
  def upgrade_customization!
    if customization_of.blank?
      raise _('upgrade_customization! requires a customised template')
    end
    funder_template = Template.published(customization_of).first

    if funder_template.blank?
      raise _("upgrade_customization! cannot be carried out since there is no published template of its current funder")
    end

    # preserves modifiable flags from the self template copied
    source = deep_copy(attributes: { version: version + 1, published: false })

    # Creates a new customisation for the published template whose family_id is
    # self.customization_of
    customization = funder_template.deep_copy(
      attributes: {
        version: source.version,
        published: source.published,
        family_id: source.family_id,
        customization_of: source.customization_of,
        org: source.org,
        visibility: Template.visibilities[:organisationally_visible],
        is_default: false
      }, modifiable: false, save: true
    )

    # Sorts the phases from the source template, i.e. self
    sorted_phases = source.phases.sort_by(&:number)

    # Merges modifiable sections or questions from source into customization
    # template object
    customization.phases.each do |customization_phase|
      # Search for the phase in the source template whose number matches the
      # customization_phase

      candidate_phase = sorted_phases.bsearch do |phase|
        customization_phase.number <=> phase.number
      end

      # The funder could have added this new phase after the customisation took
      # place
      next if candidate_phase.blank?
      # Selects modifiable sections from the candidate_phase
      modifiable_sections = candidate_phase.sections.select(&:modifiable)

      # Attaches modifiable sections into the customization_phase
      modifiable_sections.each { |modifiable_section| customization_phase.sections << modifiable_section }

      # Sorts the sections for the customization_phase
      sorted_sections = customization_phase.sections.sort_by(&:number)

      # Selects unmodifiable sections from the candidate_phase
      unmodifiable_sections = candidate_phase.sections.reject(&:modifiable)

      unmodifiable_sections.each do |unmodifiable_section|
        # Search for modifiable questions within the unmodifiable_section
        # from candidate_phase
        modifiable_questions  = unmodifiable_section.questions.select(&:modifiable)
        customization_section = sorted_sections.bsearch { |section| unmodifiable_section.number <=> section.number }
        # The funder could have deleted the section
        if customization_section.present?
          modifiable_questions.each { |modifiable_question| customization_section.questions << modifiable_question; }
        end
        # Search for unmodifiable questions within the unmodifiable_section in case source template added annotations
        unmodifiable_questions = unmodifiable_section.questions.reject(&:modifiable)
        sorted_questions = customization_section.questions.sort_by(&:number)
        unmodifiable_questions.each do |unmodifiable_question|
          customization_question = sorted_questions.bsearch { |question| unmodifiable_question.number <=> question.number }
          if customization_question.present?  # The funder could have deleted the question
            annotations_added_by_customiser = unmodifiable_question.annotations.select { |annotation| annotation.org_id == source.org_id }
            annotations_added_by_customiser.each { |annotation| customization_question.annotations << annotation }
          end
        end
      end
    end
    # Appends the modifiable phases from source
    source.phases.select(&:modifiable).each do |modifiable_phase|
      customization.phases << modifiable_phase
    end
    customization
  end

  private

  # ============================
  # = Private instance methods =
  # ============================

  # Generate a new random family identifier
  def new_family_id
    family_id = loop do
      random = rand 2_147_483_647
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
    self.visibility = (org.present? && org.funder_only?) || is_default? ? Template.visibilities[:publicly_visible] : Template.visibilities[:organisationally_visible] if id.blank?
    self.customization_of ||= nil
    self.family_id ||= new_family_id
    self.archived ||= false
    self.links ||= { funder: [], sample_plan: [] }
  end

  # Only one version of a template should be published at a time, so if this
  # one was published make sure other versions are not
  def reconcile_published
    # Unpublish all other versions of this template family
    Template.published
            .where(family_id: family_id)
            .where.not(id: id)
            .update_all(published: false)
  end
end
