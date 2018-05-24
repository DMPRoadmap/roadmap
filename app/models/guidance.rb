# [+Project:+] DMPRoadmap
# [+Description:+]
#   This class keeps the information organisations enter to support users when answering questions.
#   It always belongs to a guidance group class and it can be linked directly to a question or through one or more themes
# [+Created:+] 07/07/2014
# [+Copyright:+] Digital Curation Centre and California Digital Library



class Guidance < ActiveRecord::Base
  include GlobalHelpers

  ##
  # Associations
  belongs_to :guidance_group
  has_and_belongs_to_many :themes, join_table: "themes_in_guidance"
# depricated, but required for migration "single_group_for_guidance"
  #has_and_belongs_to_many :guidance_groups, join_table: "guidance_in_group"


  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?




  validates :text, presence: {message: _("can't be blank")}

  # Retrieves every guidance associated to an org
  scope :by_org, -> (org) {
    joins(:guidance_group).merge(GuidanceGroup.by_org(org))
  }

  scope :search, -> (term) {
    search_pattern = "%#{term}%"
    joins(:guidance_group).where("guidances.text LIKE ? OR guidance_groups.name LIKE ?", search_pattern, search_pattern)
  }
  ##
  # Determine if a guidance is in a group which belongs to a specified organisation
  #
  # @param org_id [Integer] the integer id for an organisation
  # @return [Boolean] true if this guidance is in a group belonging to the specified organisation, false otherwise
	def in_group_belonging_to?(org_id)
    unless guidance_group.nil?
  		if guidance_group.org.id == org_id
  			return true
  		end
    end
		return false
	end

  ##
  # returns all templates belgonging to a specified guidance group
  #
  # @param guidance_group [Integer] the integer id for an guidance_group
  # @return [Array<Templates>] list of templates
	def get_guidance_group_templates? (guidance_group)
    # DISCUSS - here we have yet another way of finding a specific or group of
    # an object.  Would it make sense to standardise the project by only using
    # either finders or where, or alteast the same syntax within the where statement.
    # Also why is this a ? method... it dosent return a boolean
    # Additionally, shouldnt this be a function of guidance group, not guidance?
    # and finally, it should be a self.method, as it dosent care about the guidance it's acting on
			templates = guidancegroups.where("guidance_group_id (?)", guidance_group.id).template
			return templates
	end

  ##
  # Returns whether or not a given user can view a given guidance
  # we define guidances viewable to a user by those owned by a guidance group:
  #   owned by the managing curation center
  #   owned by a funder organisation
  #   owned by an organisation, of which the user is a member
  #
  # @param id [Integer] the integer id for a guidance
  # @param user [User] a user object
  # @return [Boolean] true if the specified user can view the specified guidance, false otherwise
  def self.can_view?(user, id)
    guidance = Guidance.find_by(id: id)
    viewable = false

    unless guidance.nil?
      unless guidance.guidance_group.nil?
        # guidances are viewable if they are owned by the user's org
        if guidance.guidance_group.org == user.org
          viewable = true
        end
        # guidance groups are viewable if they are owned by the Managing Curation Center
        if Org.managing_orgs.include?(guidance.guidance_group.org)
          viewable = true
        end

        # guidance groups are viewable if they are owned by a funder
        if Org.funder.include?(guidance.guidance_group.org)
          viewable = true
        end
      end
    end

    return viewable
  end

  ##
  # Returns a list of all guidances which a specified user can view
  # we define guidances viewable to a user by those owned by a guidance group:
  #   owned by the Managing Curation Center
  #   owned by a funder organisation
  #   owned by an organisation, of which the user is a member
  #
  # @param user [User] a user object
  # @return [Array<Guidance>] a list of all "viewable" guidances to a user
  def self.all_viewable(user)
    managing_groups = Org.includes(guidance_groups: :guidances).managing_orgs.collect{|o| o.guidance_groups}
    # find all groups owned by a Funder organisation
    funder_groups = Org.includes(guidance_groups: :guidances).funder.collect{|org| org.guidance_groups}
    # find all groups owned by any of the user's organisations
    organisation_groups = user.org.guidance_groups

    # find all guidances belonging to any of the viewable groups
    all_viewable_groups = (managing_groups + funder_groups + organisation_groups).flatten
    all_viewable_guidances = all_viewable_groups.collect{|group| group.guidances}
    # pass the list of viewable guidances to the view
    return all_viewable_guidances.flatten
  end
end
