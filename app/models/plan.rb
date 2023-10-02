# frozen_string_literal: true

# The central model object within this domain. Represents a Data Management
# Plan for a research project.
#
# == Schema Information
#
# Table name: plans
#
#  id                                :integer          not null, primary key
#  complete                          :boolean          default(FALSE)
#  description                       :text
#  feedback_requested                :boolean          default(FALSE)
#  identifier                        :string
#  title                             :string
#  visibility                        :integer          default(3), not null
#  created_at                        :datetime
#  updated_at                        :datetime
#  funder_id                         :integer
#  grant_id                          :integer
#  api_client_id                     :integer
#  research_domain_id                :bigint
#  funding_status                    :integer
#  ethical_issues                    :boolean
#  ethical_issues_description        :text
#  ethical_issues_report             :string
#  feedback_start_at                 :datetime
#  feedback_end_at                   :datetime
#  subscriber_job_status             :string
#  publisher_job_status              :string
#
# Indexes
#
#  index_plans_on_funder_id    (funder_id)
#  index_plans_on_grant_id     (grant_id)
#  index_plans_on_org_id       (org_id)
#  index_plans_on_template_id  (template_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (api_client_id => api_clients.id)
#  fk_rails_...  (research_domain_id => research_domains.id)
#

# Object that represents an DMP
# rubocop:disable Metrics/ClassLength
class Plan < ApplicationRecord
  include ConditionalUserMailer
  include ExportablePlan
  include DateRangeable
  include Identifiable

  # ----------------------------------------
  # Start DMPTool Customization
  # ----------------------------------------
  include Dmptool::Plan
  include Dmptool::Registerable

  # DMPTool customization to support faceting the public plans by language
  # ----------------------------------------------------------------------
  belongs_to :language, default: -> { Language.default }

  # ActiveStorage for Narrative PDF document
  # The narrative is only pre-generated and stored in S3 if it is public. The system will still generate the PDF
  # on the fly if the user is logged in and requesting it from the 'Download' tab. If a request is made for the
  # PDF from the 'Public DMPs' page then the copy in the S3 bucket is used
  has_one_attached :narrative

  # =============
  # = Constants =
  # =============

  DMP_ID_TYPES = %w[ark doi].freeze

  # Returns visibility message given a Symbol type visibility passed, otherwise
  # nil
  VISIBILITY_MESSAGE = {
    organisationally_visible: _('organisational'),
    publicly_visible: _('public'),
    is_test: _('test'),
    privately_visible: _('private')
  }.freeze

  FUNDING_STATUS = {
    planned: _('Planned'),
    funded: _('Funded'),
    denied: _('Denied')
  }.freeze

  # ==============
  # = Attributes =
  # ==============

  # public is a Ruby keyword so using publicly
  enum visibility: { organisationally_visible: 0, publicly_visible: 1, is_test: 2, privately_visible: 3 }

  enum funding_status: { planned: 0, funded: 1, denied: 2 }

  alias_attribute :name, :title

  # ================
  # = Associations =
  # ================

  belongs_to :template

  belongs_to :org

  belongs_to :funder, class_name: 'Org', optional: true

  belongs_to :api_client, optional: true

  belongs_to :research_domain, optional: true

  has_many :phases, through: :template

  has_many :sections, through: :phases

  has_many :questions, through: :sections

  has_many :themes, through: :questions

  has_many :guidances, through: :themes

  has_many :guidance_group_options, -> { distinct.includes(:org).published.reorder('id') },
           through: :guidances,
           source: :guidance_group,
           class_name: 'GuidanceGroup'

  has_many :answers, dependent: :destroy

  has_many :notes, through: :answers

  has_many :roles, dependent: :destroy

  has_many :users, through: :roles

  has_and_belongs_to_many :guidance_groups, join_table: :plans_guidance_groups

  has_many :exported_plans, dependent: :destroy

  has_many :contributors, dependent: :destroy

  has_one :grant, as: :identifiable, dependent: :destroy, class_name: 'Identifier'

  has_many :research_outputs, dependent: :destroy

  has_many :subscriptions, dependent: :destroy

  has_many :related_identifiers, as: :identifiable, dependent: :destroy

  # =====================
  # = Nested Attributes =
  # =====================

  accepts_nested_attributes_for :template

  accepts_nested_attributes_for :roles

  accepts_nested_attributes_for :contributors

  accepts_nested_attributes_for :research_outputs

  # ===============
  # = Validations =
  # ===============

  validates :title, presence: { message: PRESENCE_MESSAGE }

  validates :template, presence: { message: PRESENCE_MESSAGE }

  validates :feedback_requested, inclusion: { in: BOOLEAN_VALUES }

  validates :complete, inclusion: { in: BOOLEAN_VALUES }

  validate :end_date_after_start_date

  # =============
  # = Callbacks =
  # =============

  # sanitise html tags e.g remove unwanted 'script'
  before_validation lambda { |data|
    data.sanitize_fields(:title, :identifier, :description)
  }
  after_update :notify_subscribers!, if: :versionable_change?
  after_touch :notify_subscribers!

  after_update :store_narrative, if: :publicly_visible?
  after_touch :store_narrative, if: :publicly_visible?

  # ==========
  # = Scopes =
  # ==========

  # Retrieves any plan in which the user has an active role and
  # is not a reviewer
  scope :active, lambda { |user|
    plan_ids = Role.where(active: true, user_id: user.id).pluck(:plan_id)

    includes(:template, :roles)
      .where(id: plan_ids)
  }

  # Retrieves any plan organisationally or publicly visible for a given org id
  scope :organisationally_or_publicly_visible, lambda { |user|
    plan_ids = user.org.org_admin_plans.where(complete: true).pluck(:id).uniq
    includes(:template, roles: :user)
      .where(id: plan_ids, visibility: [
               visibilities[:organisationally_visible],
               visibilities[:publicly_visible]
             ])
      .where(
        'NOT EXISTS (SELECT 1 FROM roles WHERE plan_id = plans.id AND user_id = ?)',
        user.id
      )
  }

  scope :search, lambda { |term|
    if date_range?(term: term)
      joins(:template, roles: [user: :org])
        .where(roles: { active: true })
        .by_date_range(:created_at, term)
    else
      search_pattern = sanitize_sql("%#{term}%")
      joins(:template, roles: [user: :org])
        .left_outer_joins(:identifiers, :contributors)
        .where(roles: { active: true })
        .where("lower(plans.title) LIKE lower(:search_pattern)
                OR lower(orgs.name) LIKE lower (:search_pattern)
                OR lower(orgs.abbreviation) LIKE lower (:search_pattern)
                OR lower(templates.title) LIKE lower(:search_pattern)
                OR lower(contributors.name) LIKE lower(:search_pattern)
                OR lower(identifiers.value) LIKE lower(:search_pattern)",
               search_pattern: search_pattern)
    end
  }

  ##
  # Defines the filter_logic used in the statistics objects.
  # For now, we filter out any test plans
  scope :stats_filter, -> { where.not(visibility: visibilities[:is_test]) }

  # Retrieves plan, template, org, phases, sections and questions
  scope :overview, lambda { |id|
    includes(:phases, :sections, :questions, template: [:org]).find(id)
  }

  ##
  # Settings for the template
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end
  alias super_settings settings

  # =============
  # = Callbacks =
  # =============

  # =================
  # = Class methods =
  # =================

  # Pre-fetched a plan phase together with its sections and questions
  # associated. It also pre-fetches the answers and notes associated to the plan
  def self.load_for_phase(plan_id, phase_id)
    # Preserves the default order defined in the model relationships
    plan = Plan.joins(template: { phases: { sections: :questions } })
               .preload(template: { phases: { sections: :questions } })
               .where(id: plan_id, phases: { id: phase_id })
               .merge(Plan.includes(answers: :notes)).first
    phase = plan.template.phases.find { |p| p.id == phase_id.to_i }

    [plan, phase]
  end

  # deep copy the given plan and all of it's associations
  # create
  # plan - Plan to be deep copied
  #
  # Returns Plan
  # rubocop:disable Metrics/AbcSize
  def self.deep_copy(plan)
    plan_copy = plan.dup
    plan_copy.title = "Copy of #{plan.title}"
    plan_copy.feedback_requested = false
    plan_copy.feedback_start_at = nil
    plan_copy.feedback_end_at = nil
    plan_copy.save!
    plan.answers.each do |answer|
      answer_copy = Answer.deep_copy(answer)
      answer_copy.plan_id = plan_copy.id
      answer_copy.save!
    end
    plan.guidance_groups.each do |guidance_group|
      plan_copy.guidance_groups << guidance_group if guidance_group.present?
    end
    plan_copy
  end
  # rubocop:enable Metrics/AbcSize

  # ===========================
  # = Public instance methods =
  # ===========================

  ##
  # Proxy through to the template settings (or defaults if this plan doesn't
  # have an associated template) if there are no settings stored for this plan.
  #
  # TODO: Update this comment below. AFAIK `key` has nothing to do with Rails.
  # key - Is required by rails-settings, so it's required here, too.
  #
  # Returns Hash
  def settings(key)
    self_settings = super_settings(key)
    return self_settings if self_settings.value?

    template&.settings(key)
  end

  # The most recent answer to the given question id optionally can create an answer if
  # none exists.
  #
  # qid               - The id for the question to find the answer for
  # create_if_missing - If true, will genereate a default answer
  #                     to the question (defaults: true).
  #
  # Returns Answer
  # Returns nil
  # rubocop:disable Metrics/AbcSize, Style/OptionalBooleanParameter
  def answer(qid, create_if_missing = true)
    answer = answers.select { |a| a.question_id == qid }
                    .max_by(&:created_at)
    if answer.nil? && create_if_missing
      question = Question.find(qid)
      answer = Answer.new
      answer.plan_id     = id
      answer.question_id = qid
      answer.text        = question.default_value
      default_options    = []
      question.question_options.each do |option|
        default_options << option if option.is_default
      end
      answer.question_options = default_options
    end
    answer
  end
  # rubocop:enable Metrics/AbcSize, Style/OptionalBooleanParameter

  alias get_guidance_group_options guidance_group_options

  deprecate :get_guidance_group_options,
            deprecator: Cleanup::Deprecators::GetDeprecator.new

  ##
  # Sets up the plan for feedback:
  #  emails confirmation messages to owners
  #  emails org admins and org contact
  #  adds org admins to plan with the 'reviewer' Role
  # rubocop:disable Metrics/AbcSize
  def request_feedback(user)
    Plan.transaction do
      self.feedback_requested = true
      self.feedback_start_at = Time.now
      self.feedback_end_at = nil
      return false unless save!

      # Send an email to the org-admin contact
      if user.org.contact_email.present?
        contact = User.new(email: user.org.contact_email,
                           firstname: user.org.contact_name)
        UserMailer.feedback_notification(contact, self, user).deliver_now
      end
      true
    rescue StandardError => e
      Rails.logger.error e
      false
    end
  end
  # rubocop:enable Metrics/AbcSize

  ##
  # Finalizes the feedback for the plan: Emails confirmation messages to owners
  # sets flag on plans.feedback_requested to false removes org admins from the
  # 'reviewer' Role for the Plan.
  def complete_feedback(org_admin)
    Plan.transaction do
      self.feedback_requested = false
      self.feedback_end_at = Time.now
      return false unless save!

      # Send an email confirmation to the owners and co-owners
      deliver_if(recipients: owner_and_coowners,
                 key: 'users.feedback_provided') do |r|
        UserMailer.feedback_complete(
          r,
          self,
          org_admin
        ).deliver_now
      end
      true
    rescue StandardError => e
      Rails.logger.error e
      false
    end
  end

  ##
  # determines if the plan is editable by the specified user
  #
  # user_id - The id for a user
  #
  # Returns Boolean
  def editable_by?(user_id)
    roles.any? { |r| r.user_id == user_id && r.active && r.editor }
  end

  ##
  # determines if the plan is readable by the specified user
  #
  # user_id - The Integer id for a user
  #
  # Returns Boolean
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def readable_by?(user_id)
    return true if commentable_by?(user_id)

    current_user = User.find(user_id)
    return false if current_user.blank?

    # If the user is a super admin and the config allows for supers to view plans
    if current_user.can_super_admin? && Rails.configuration.x.plans.super_admins_read_all
      true
    # If the user is an org admin and the config allows for org admins to view plans
    elsif current_user.can_org_admin? && Rails.configuration.x.plans.org_admins_read_all
      owner_and_coowners.map(&:org_id).include?(current_user.org_id)
    else
      false
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # determines if the plan is readable by the specified user.
  #
  # user_id - The Integer id for a user
  #
  # Returns Boolean
  def commentable_by?(user_id)
    roles.any? { |r| r.user_id == user_id && r.active && r.commenter } ||
      reviewable_by?(user_id)
  end

  # determines if the plan is administerable by the specified user
  #
  # user_id - The Integer id for the user
  #
  # Returns Boolean
  def administerable_by?(user_id)
    roles.any? { |r| r.user_id == user_id && r.active && r.administrator }
  end

  # determines if the plan is reviewable by the specified user
  #
  # user_id - The Integer id for the user
  #
  # Returns Boolean
  def reviewable_by?(user_id)
    reviewer = User.find(user_id)
    feedback_requested? &&
      reviewer.present? &&
      reviewer.org_id == owner&.org_id &&
      reviewer.can_review_plans?
  end

  # the datetime for the latest update of this plan
  #
  # Returns DateTime
  def latest_update
    (phases.pluck(:updated_at) + [updated_at]).max
  end

  # The owner (aka :creator) of the project
  #
  # Returns User
  # Returns nil
  def owner
    r = roles.select { |rr| rr.active && rr.administrator }
             .min_by(&:created_at)
    r&.user
  end

  # Creates a role for the specified user (will update the user's
  # existing role if it already exists)
  #
  # Expects a User.id and access_type from the following list:
  #  :creator, :administrator, :editor, :commenter
  #
  # Returns Boolean
  def add_user!(user_id, access_type = :commenter)
    user = User.where(id: user_id).first
    if user.present?
      role = Role.find_or_initialize_by(user_id: user_id, plan_id: id)

      # Access is cumulative, so set the appropriate flags
      # (e.g. an administrator can also edit and comment)
      case access_type
      when :creator
        role.creator = true
        role.administrator = true
        role.editor = true
      when :administrator
        role.administrator = true
        role.editor = true
      when :editor
        role.editor = true
      end
      role.commenter = true
      role.save
    else
      false
    end
  end

  ##
  # Whether or not the plan is associated with users other than the creator
  #
  # Returns Boolean
  def shared?
    roles.select(&:active).reject(&:creator).any?
  end

  alias shared shared?

  deprecate :shared, deprecator: Cleanup::Deprecators::PredicateDeprecator.new

  # The owner and co-owners (aka :creator and :administrator) of the project
  #
  # Returns ActiveRecord::Relation
  def owner_and_coowners
    # We only need to search for :administrator in the bitflag
    # since :creator includes :administrator rights
    roles.select { |r| r.active && r.administrator && !r.user.nil? }.map(&:user).uniq
  end

  # The creator, administrator and editors
  #
  # Returns ActiveRecord::Relation
  def authors
    # We only need to search for :editor in the bitflag
    # since :creator and :administrator include :editor rights
    roles.select { |r| r.active && r.editor }.map(&:user).uniq
  end

  # The number of answered questions from the entire plan
  #
  # Returns Integer
  def num_answered_questions(phase = nil)
    return answers.count(&:answered?) unless phase.present?

    answered = answers.select do |answer|
      answer.answered? && phase.questions.include?(answer.question)
    end
    answered.length
  end

  # The number of questions for a plan.
  #
  # Returns Integer
  def num_questions
    questions.count
  end

  # Determines whether or not visibility changes are permitted according to the
  # percentage of the plan answered in respect to a threshold defined at
  # application.config
  #
  # Returns Boolean
  def visibility_allowed?
    !is_test? && phases.any? { |phase| phase.visibility_allowed?(self) }
  end

  # Determines whether or not a question (given its id) exists for the self plan
  #
  # Returns Boolean
  def question_exists?(question_id)
    Plan.joins(:questions).exists?(id: id, 'questions.id': question_id)
  end

  # Determines what percentage of the Plan's questions have been num_answered_questions
  #
  def percent_answered
    num_questions = question_ids.length
    return 0 unless num_questions.positive?

    pre_fetched_answers = Answer.includes(:question_options,
                                          question: :question_format)
                                .where(id: answer_ids)
    num_answers = pre_fetched_answers.reduce(0) do |m, a|
      m += 1 if a.answered?
      m
    end
    return 0 unless num_answers.positive?

    (num_answers / num_questions.to_f) * 100
  end

  # Deactivates the plan (sets all roles to inactive and visibility to :private)
  #
  # Returns Boolean
  def deactivate!
    # If no other :creator, :administrator or :editor is attached
    # to the plan, then also deactivate all other active roles
    # and set the plan's visibility to :private
    if authors.empty?
      roles.where(active: true).update_all(active: false)
      self.visibility = Plan.visibilities[:privately_visible]
      save!
    else
      false
    end
  end

  # Since the Grant is not a normal AR association, override the getter and setter
  def grant
    Identifier.find_by(id: grant_id)
  end

  # Helper method to convert the grant id value entered by the user into an Identifier
  # works with both controller params or an instance of Identifier
  # rubocop:disable Metrics/CyclomaticComplexity
  def grant=(params)
    val = params.present? ? params[:value] : nil
    current = grant

    # Remove it if it was blanked out by the user
    current.destroy if current.present? && val.blank?
    return if val.blank?

    # Create the Identifier if it doesn't exist and then set the id
    current.update(value: val) if current.present? && current.value != val
    return if current.present?

    current = Identifier.create(identifiable: self, value: val)
    self.grant_id = current.id
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # Returns the Subscription for the specified subscriber or nil if none exists
  def subscription_for(subscriber:)
    subscriptions.select { |subscription| subscription.subscriber == subscriber }
  end

  # Helper method to convert related_identifier entries from standard form params into
  # RelatedIdentifier objects.
  #
  # Expecting the hash to look like the following, where the initial key is the
  # RelatedIdentifier.id or "0" if its an empty entry or an absurdly long value
  # indicating that its a new entry.
  # The form's JS makes a copy of the "0" entry and generate a long value for an id
  # when the user clicks the '+add a related identifier' link. We need to do this so
  # that the user is able to add multiple entries at one time.
  #
  #  {
  #    "56": {
  #      "work_type": "software", "value": "https://doi.org/10.48321/D1MP4Z"
  #    },
  #    "0": {
  #      "work_type": "article", "value": ""
  #    },
  #    "1632773961597": {
  #      "work_type": "dataset", "value": "http://foo.bar"
  #    }
  #  }
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def related_identifiers_attributes=(params)
    # Remove any that the user may have deleted
    related_identifiers.reject { |r_id| params.key?(r_id.id.to_s) }.each(&:destroy)

    # Update existing or add new
    params.each do |id, related_identifier_hash|
      related_identifier_hash = related_identifier_hash.with_indifferent_access
      next unless id.present? && id != '0' && related_identifier_hash[:value].present?

      related = RelatedIdentifier.find_by(id: id)
      related = RelatedIdentifier.new(identifiable: self) if related.blank?
      related.work_type = related_identifier_hash[:work_type]
      related.value = related_identifier_hash[:value].strip
      related_identifiers << related
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

  private

  # Determines whether or not the attributes that were updated constitute a versionable change
  # for example a user requesting feedback will change the :feedback_requested flag but that
  # should not create a new version or notify any subscribers!
  #
  # Note that some associated models :touch the plan when they are updated so that a change
  # to a contributor for example will constitute a new version of the plan
  #
  # TODO: We will likely need to change this or break it up into different methods based
  #       on the use cases we uncover when deciding how to version plans
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def versionable_change?
    saved_change_to_title? || saved_change_to_description? || saved_change_to_identifier? ||
      saved_change_to_visibility? || saved_change_to_complete? || saved_change_to_template_id? ||
      saved_change_to_org_id? || saved_change_to_funder_id? || saved_change_to_grant_id? ||
      saved_change_to_start_date? || saved_change_to_end_date? ||
      saved_change_to_research_domain_id? || saved_change_to_ethical_issues? ||
      saved_change_to_ethical_issues_description? || saved_change_to_ethical_issues_report?
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # Sends notifications to the Subscribers of the specified subscription types
  def notify_subscribers!(subscription_types: [:updates])
    targets = subscription_types.map do |typ|
      subscriptions.select { |sub| sub.selected_subscription_types.include?(typ.to_sym) }
    end
    targets = targets.flatten.uniq if targets.any?
    targets.each(&:notify!)

    # Re-publish the narrative PDF document
    publish_narrative! if respond_to?(:publish_narrative!) && plan.dmp_id.present?
    true
  end

  # Validation to prevent end date from coming before the start date
  def end_date_after_start_date
    # allow nil values
    return true if end_date.blank? || start_date.blank? || end_date > start_date

    errors.add(:end_date, _('must be after the start date')) if end_date < start_date
    false
  end

  # Store the narrative in local ActiveStorage if the Plan does not have a DMP ID and it is publicly_visible
  def store_narrative
    return false unless dmp_id.nil? && publicly_visible?
    # Don't kick of the job if it is already enqueued!
    return false if publisher_job_status == 'enqueued'

    update(publisher_job_status: 'enqueued')
    PdfPublisherJob.set(wait: 5.seconds).perform_later(plan: self)
    true
  end
end
# rubocop:enable Metrics/ClassLength
