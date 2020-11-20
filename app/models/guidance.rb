# frozen_string_literal: true

# Guidance provides information from organisations to Users, helping them when
# answering questions. (e.g. "Here's how to think about your data
# protection responsibilities...")
#
# == Schema Information
#
# Table name: guidances
#
#  id                :integer          not null, primary key
#  published         :boolean
#  text              :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  guidance_group_id :integer
#
# Indexes
#
#  index_guidances_on_guidance_group_id  (guidance_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (guidance_group_id => guidance_groups.id)
#

# [+Project:+] DMPRoadmap
# [+Description:+]
#   This class keeps the information organisations enter to support users
#   when answering questions.
#   It always belongs to a guidance group class and it can be linked directly
#   to a question or through one or more themes
# [+Created:+] 07/07/2014
# [+Copyright:+] Digital Curation Centre and California Digital Library

class Guidance < ApplicationRecord

  # ================
  # = Associations =
  # ================

  belongs_to :guidance_group

  has_and_belongs_to_many :themes, join_table: "themes_in_guidance"

  # ===============
  # = Validations =
  # ===============

  validates :text, presence: { message:  PRESENCE_MESSAGE }

  validates :guidance_group, presence: { message: PRESENCE_MESSAGE }

  validates :published, inclusion: { message: INCLUSION_MESSAGE,
                                     in: BOOLEAN_VALUES }

  validates :themes, presence: { message: PRESENCE_MESSAGE }, if: :published?

  # Retrieves every guidance associated to an org
  scope :by_org, lambda { |org|
    joins(:guidance_group).merge(GuidanceGroup.by_org(org))
  }

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    joins(:guidance_group)
      .where("lower(guidances.text) LIKE lower(?) OR " \
            "lower(guidance_groups.name) LIKE lower(?)",
             search_pattern,
             search_pattern)
  }

  # =================
  # = Class methods =
  # =================

  # Returns whether or not a given user can view a given guidance
  # we define guidances viewable to a user by those owned by a guidance group:
  #   owned by the default orgs
  #   owned by a funder organisation
  #   owned by an organisation, of which the user is a member
  #
  # id   - The Integer id for a guidance
  # user - A User object
  #
  # Returns Boolean
  def self.can_view?(user, id)
    guidance = Guidance.find_by(id: id)
    viewable = false

    unless guidance.nil?
      unless guidance.guidance_group.nil?
        # guidances are viewable if they are owned by the user's org
        viewable = true if guidance.guidance_group.org == user.org
        # guidance groups are viewable if they are owned by the Default Orgs
        viewable = true if Org.default_orgs.include?(guidance.guidance_group.org)

        # guidance groups are viewable if they are owned by a funder
        viewable = true if Org.funder.include?(guidance.guidance_group.org)
      end
    end

    viewable
  end

  # Returns a list of all guidances which a specified user can view
  # we define guidances viewable to a user by those owned by a guidance group:
  #   owned by the Default Orgs
  #   owned by a funder organisation
  #   owned by an organisation, of which the user is a member
  #
  # user - A User object
  #
  # Returns Array
  def self.all_viewable(user)
    default_groups = Org.includes(guidance_groups: :guidances)
                        .default_orgs.collect(&:guidance_groups)
    # find all groups owned by a Funder organisation
    funder_groups = Org.includes(guidance_groups: :guidances)
                       .funder.collect(&:guidance_groups)
    # find all groups owned by any of the user's organisations
    organisation_groups = user.org.guidance_groups

    # find all guidances belonging to any of the viewable groups
    all_viewable_groups = (default_groups +
                            funder_groups +
                            organisation_groups).flatten
    all_viewable_guidances = all_viewable_groups.collect(&:guidances)
    # pass the list of viewable guidances to the view
    all_viewable_guidances.flatten
  end

  # Determine if a guidance is in a group which belongs to a specified
  # organisation
  #
  # org_id - The Integer id for an organisation
  #
  # Returns Boolean
  def in_group_belonging_to?(org_id)
    unless guidance_group.nil?
      return true if guidance_group.org.id == org_id
    end
    false
  end

end
