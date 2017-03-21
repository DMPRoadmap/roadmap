# [+Project:+] DMPRoadmap
# [+Description:+]
#   This class keeps the information organisations enter to support users when answering questions.
#   It always belongs to a guidance group class and it can be linked directly to a question or through one or more themes
# [+Created:+] 07/07/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center



class Guidance < ActiveRecord::Base
  include GlobalHelpers
  #associations between tables
	attr_accessible :text, :question_id, :published, :as => [:default, :admin]

  attr_accessible :guidance_group_ids, :as => [:default, :admin]
  attr_accessible :theme_ids, :as => [:default, :admin]

  belongs_to :question

  #belongs_to :dmptemplate
  #belongs_to :theme

  has_and_belongs_to_many :guidance_groups, join_table: "guidance_in_group"
  has_and_belongs_to_many :themes, join_table: "themes_in_guidance"

  accepts_nested_attributes_for :themes
  accepts_nested_attributes_for :guidance_groups


  ##
  # Determine if a guidance is in a group which belongs to a specified organisation
  #
  # @param org_id [Integer] the integer id for an organisation
  # @return [Boolean] true if this guidance is in a group belonging to the specified organisation, false otherwise
	def in_group_belonging_to?(organisation_id)
		guidance_groups.each do |guidance_group|
			if guidance_group.organisation_id == organisation_id
				return true
			end
		end
		return false
	end

  ##
  # returns all guidance that belongs to a specified organisation
  #
  # @param org_id [Integer] the integer id for an organisation
  # @return [Array<Guidance>] list of guidance
	def self.by_organisation(org_id)
    org_guidance = []
    Organisation.find_by(id: org_id).guidance_groups.each do |group|
      org_guidance += group.guidances
    end
		return org_guidance
	end

  ##
  # returns all templates belgonging to a specified guidance group
  #
  # @param guidance_group [Integer] the integer id for an guidance_group
  # @return [Array<Dmptemplates>] list of templates
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

    # guidances may belong to many guidance groups, so we check the above case for each
    guidance.guidance_groups.each do |guidance_group|

      # guidances are viewable if they are owned by any of the user's organisations
      user.organisations.each do |organisation|
        
        if guidance_group.organisation.id == organisation.id
          viewable = true
        end
      end

      # guidance groups are viewable if they are owned by the Managing Curation Center
      if guidance_group.organisation.id == Organisation.find_by( name: GlobalHelpers.constant("organisation_types.managing_organisation")).id
        viewable = true
      end

      # guidance groups are viewable if they are owned by a funder
      if guidance_group.organisation.organisation_type == OrganisationType.find_by( name: GlobalHelpers.constant("organisation_types.funder"))
        viewable = true
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
    managing_groups = (Organisation.find_by name: GlobalHelpers.constant("organisation_types.managing_organisation")).guidance_groups
    # find all groups owned by a Funder organisation
    funder_groups = []
    funders = OrganisationType.find_by( name: GlobalHelpers.constant("organisation_types.funder"))
    funders.organisations.each do |funder|
      funder_groups += funder.guidance_groups
    end
    # find all groups owned by any of the user's organisations
    organisation_groups = []
    user.organisations.each do |organisation|
      organisation_groups += organisation.guidance_groups
    end
    # find all guidances belonging to any of the viewable groups
    all_viewable_guidances = []
    all_viewable_groups = managing_groups + funder_groups + organisation_groups
    all_viewable_groups.each do |group|
      all_viewable_guidances += group.guidances
    end
    # pass the list of viewable guidances to the view
    return all_viewable_guidances
  end

end
