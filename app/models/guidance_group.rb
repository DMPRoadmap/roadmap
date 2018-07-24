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

  ##
  # Associations
  belongs_to :org
  has_many :guidances, dependent: :destroy
  has_and_belongs_to_many :plans, join_table: :plans_guidance_groups
  # depricated but needed for migration "single_group_for_guidance"
  # has_and_belongs_to_many :guidances, join_table: "guidance_in_group"


  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message:  PRESENCE_MESSAGE }

  validates :org, presence: { message: PRESENCE_MESSAGE }

  validates :optional_subset, inclusion: { in: BOOLEAN_VALUES,
                                           message: INCLUSION_MESSAGE }

  validates :published, inclusion: { in: BOOLEAN_VALUES,
                                     message: INCLUSION_MESSAGE }


  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?

  # Retrieves every guidance group associated to an org
  scope :by_org, -> (org) {
    where(org_id: org.id)
  }
  scope :search, -> (term) {
    search_pattern = "%#{term}%"
    where("name LIKE ?", search_pattern)
  }

  ##
  # Converts the current guidance group to a string containing the display name.
  # If it's organisation has no other guidance groups, then the name is simply
  # the name of the parent organisation, otherwise it returns the name of the
  # organisation followed by the name of the guidance group.
  #
  # @return [String] the display name for the guidance group
	def display_name
		if org.guidance_groups.count > 1
			return "#{org.name}: #{name}"
		else
			return org.name
		end
	end

  ##
  # Returns the list of all guidance groups not coming from the given organisations
  #
  # @param excluded_orgs [Array<Organisation>] a list of organisations to exclude in the result
  # @return [Array<GuidanceGroup>] a list of guidance groups
  def self.guidance_groups_excluding(excluded_orgs)
    excluded_org_ids = Array.new

    if excluded_orgs.is_a?(Array)
      excluded_orgs.each do |org|
        excluded_org_ids << org.id
      end
    else
      excluded_org_ids << excluded_orgs
    end

    return_orgs =  GuidanceGroup.where("org_id NOT IN (?)", excluded_org_ids)
    return return_orgs
  end

  ##
  # Returns whether or not a given user can view a given guidance group
  # we define guidances viewable to a user by those owned by:
  #   the managing curation center
  #   a funder organisation
  #   an organisation, of which the user is a member
  #
  # @param id [Integer] the integer id for a guidance group
  # @param user [User] a user object
  # @return [Boolean] true if the specified user can view the specified guidance group, false otherwise
  def self.can_view?(user, guidance_group)
    viewable = false
    # groups are viewable if they are owned by any of the user's organisations
    if guidance_group.org == user.org
      viewable = true
    end
    # groups are viewable if they are owned by the managing curation center
    Org.managing_orgs.each do |managing_group|
      if guidance_group.org.id == managing_group.id
        viewable = true
      end
    end
    # groups are viewable if they are owned by a funder
    if guidance_group.org.funder?
      viewable = true
    end

    return viewable
  end

    ##
    # Returns a list of all guidance groups which a specified user can view
    # we define guidance groups viewable to a user by those owned by:
    #   the Managing Curation Center
    #   a funder organisation
    #   an organisation, of which the user is a member
    #
    # @param user [User] a user object
    # @return [Array<GuidanceGroup>] a list of all "viewable" guidance groups to a user
  def self.all_viewable(user)
    # first find all groups owned by the Managing Curation Center
    managing_org_groups = Org.includes(guidance_groups: [guidances: :themes]).managing_orgs.collect{|org| org.guidance_groups}

    # find all groups owned by  a Funder organisation
    funder_groups = Org.includes(:guidance_groups).funder.collect{|org| org.guidance_groups}

    organisation_groups = [user.org.guidance_groups]

    # pass this organisation guidance groups to the view with respond_with @all_viewable_groups
    all_viewable_groups = managing_org_groups + funder_groups + organisation_groups
    all_viewable_groups = all_viewable_groups.flatten.uniq
    return all_viewable_groups
  end
end
