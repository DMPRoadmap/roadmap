# Set of Guidances that pertain to a certain category of Users (e.g. Maths
# department, vs Biology department)
#
# == Schema Information
#
# Table name: guidance_groups
#
#  id              :integer          not null, primary key
#  name            :string
#  optional_subset :boolean
#  published       :boolean
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
class GuidanceGroup < ActiveRecord::Base
  include GlobalHelpers
  include ValidationValues
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  belongs_to :org

  has_many :guidances, dependent: :destroy

  has_and_belongs_to_many :plans, join_table: :plans_guidance_groups

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message:  PRESENCE_MESSAGE },
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
    where("name LIKE ?", search_pattern)
  }

  scope :published, -> { where(published: true) }

  # =================
  # = Class methods =
  # =================

  ##
  # Returns whether or not a given user can view a given guidance group
  # we define guidances viewable to a user by those owned by:
  #   the managing curation center
  #   a funder organisation
  #   an organisation, of which the user is a member
  #
  # @param id [Integer] the integer id for a guidance group
  # @param user [User] a user object
  # @return [Boolean] true if the specified user can view the specified
  # guidance group, false otherwise
  def self.can_view?(user, guidance_group)
    viewable = false
    # groups are viewable if they are owned by any of the user's organisations
    viewable = true if guidance_group.org == user.org
    # groups are viewable if they are owned by the managing curation center
    Org.managing_orgs.each do |managing_group|
      viewable = true if guidance_group.org.id == managing_group.id
    end
    # groups are viewable if they are owned by a funder
    viewable = true if guidance_group.org.funder?

    viewable
  end

  ##
  # Returns a list of all guidance groups which a specified user can view
  # we define guidance groups viewable to a user by those owned by:
  #   the Managing Curation Center
  #   a funder organisation
  #   an organisation, of which the user is a member
  #
  # @param user [User] a user object
  # @return [Array<GuidanceGroup>] a list of all "viewable" guidance groups to
  # a user
  def self.all_viewable(user)
    # first find all groups owned by the Managing Curation Center
    managing_org_groups = Org.includes(guidance_groups: [guidances: :themes])
                             .managing_orgs.collect(&:guidance_groups)

    # find all groups owned by  a Funder organisation
    funder_groups = Org.includes(:guidance_groups)
                       .funder
                       .collect(&:guidance_groups)

    organisation_groups = [user.org.guidance_groups]

    # pass this organisation guidance groups to the view with respond_with
    # @all_viewable_groups
    all_viewable_groups = managing_org_groups +
                          funder_groups +
                          organisation_groups
    all_viewable_groups = all_viewable_groups.flatten.uniq
    all_viewable_groups
  end
end
