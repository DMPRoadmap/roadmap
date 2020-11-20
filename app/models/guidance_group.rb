# frozen_string_literal: true

# Set of Guidances that pertain to a certain category of Users (e.g. Maths
# department, vs Biology department)
#
# == Schema Information
#
# Table name: guidance_groups
#
#  id              :integer          not null, primary key
#  name            :string
#  optional_subset :boolean          default(FALSE), not null
#  published       :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  org_id          :integer
#
# Indexes
#
#  index_guidance_groups_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#

class GuidanceGroup < ApplicationRecord

  attribute :optional_subset, :boolean, default: true
  attribute :published, :boolean, default: false

  # ================
  # = Associations =
  # ================

  belongs_to :org

  has_many :guidances, dependent: :destroy

  has_and_belongs_to_many :plans, join_table: :plans_guidance_groups

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE, scope: :org_id }

  validates :org, presence: { message: PRESENCE_MESSAGE }

  validates :optional_subset, inclusion: { in: BOOLEAN_VALUES,
                                           message: INCLUSION_MESSAGE }

  validates :published, inclusion: { in: BOOLEAN_VALUES,
                                     message: INCLUSION_MESSAGE }

  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?

  # Retrieves every guidance group associated to an org
  scope :by_org, ->(org) { where(org_id: org.id) }

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    where("lower(name) LIKE lower(?)", search_pattern)
  }

  scope :published, -> { where(published: true) }

  # =================
  # = Class methods =
  # =================

  # Whether or not a given user can view a given guidance group
  # we define guidances viewable to a user by those owned by:
  #   the default orgs
  #   a funder organisation
  #   an organisation, of which the user is a member
  #
  # id   - The integer id for a guidance group
  # user - A User object
  #
  # Returns Boolean
  def self.can_view?(user, guidance_group)
    viewable = false
    # groups are viewable if they are owned by any of the user's organisations
    viewable = true if guidance_group.org == user.org
    # groups are viewable if they are owned by the default org
    Org.default_orgs.each do |default_org|
      viewable = true if guidance_group.org.id == default_org.id
    end
    # groups are viewable if they are owned by a funder
    viewable = true if guidance_group.org.funder?

    viewable
  end

  # A list of all guidance groups which a specified user can view
  # we define guidance groups viewable to a user by those owned by:
  #   the Default Orgs
  #   a funder organisation
  #   an organisation, of which the user is a member
  #
  # user - A User object
  #
  # Returns Array
  def self.all_viewable(user)
    # first find all groups owned by the Default Orgs
    default_org_groups = Org.includes(guidance_groups: [guidances: :themes])
                            .default_orgs.collect(&:guidance_groups)

    # find all groups owned by  a Funder organisation
    funder_groups = Org.includes(:guidance_groups)
                       .funder
                       .collect(&:guidance_groups)

    organisation_groups = [user.org.guidance_groups]

    # pass this organisation guidance groups to the view with respond_with
    # all_viewable_groups
    all_viewable_groups = default_org_groups +
                          funder_groups +
                          organisation_groups
    all_viewable_groups = all_viewable_groups.flatten.uniq
    all_viewable_groups
  end

  def self.create_org_default(org)
    GuidanceGroup.create!(
      name: org.abbreviation? ? org.abbreviation : org.name,
      org: org,
      optional_subset: false
    )
  end

end
