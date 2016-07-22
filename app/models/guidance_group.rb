class GuidanceGroup < ActiveRecord::Base

    #associations between tables
    belongs_to :organisation

    has_and_belongs_to_many :guidances, join_table: "guidance_in_group"

    has_and_belongs_to_many :projects, join_table: "project_guidance"
    has_and_belongs_to_many :dmptemplates, join_table: "dmptemplates_guidance_groups"

    accepts_nested_attributes_for :dmptemplates

    attr_accessible :organisation_id, :name, :optional_subset, :published, :as => [:default, :admin]
    attr_accessible :dmptemplate_ids, :as => [:default, :admin]

  ##
  # Converts a guidance group to a string containing the display name
  #
  # @return [String] the name of the organisation, with or without the name of the guidance group
	def to_s
		"#{display_name}"
	end

  ##
  # Converts the current guidance group to a string containing the display name.
  # If it's organisation has no other guidance groups, then the name is simply
  # the name of the parent organisation, otherwise it returns the name of the
  # organisation followed by the name of the guidance group.
  #
  # @return [String] the display name for the guidance group
	def display_name
		if organisation.guidance_groups.count > 1
			return "#{organisation.name}: #{name}"
		else
			return organisation.name
		end
	end

  ##
  # Returns the list of all guidance groups not coming from the given organisations
  #
  # @params excluded_orgs [Array<Organisation>] a list of organisations to exclude in the result
  # @return [Array<GuidanceGroup>] a list of guidance groups
	def self.guidance_groups_excluding(excluded_orgs)
		excluded_org_ids = Array.new
		excluded_orgs.each do |org|
			excluded_org_ids << org.id
		end
		return_orgs =  GuidanceGroup.where("organisation_id NOT IN (?)", excluded_org_ids)
		return return_orgs
	end

  ##
  # Returns whether or not a given user can view a given guidance group
  # we define guidances viewable to a user by those owned by:
  #   the DCC
  #   a funder organisation
  #   an organisation, of which the user is a member
  #
  # @param id [Integer] the integer id for a guidance group
  # @param user [User] a user object
  # @return [Boolean] true if the specified user can view the specified guidance group, false otherwise
  def self.can_view?(user, id)
  guidance_group = GuidanceGroup.find_by(id: id)
  viewable = false

  # groups are viewable if they are owned by any of the user's organisations
  user.organisations.each do |organisation|
    if guidance_group.organisation.id == organisation.id
      viewable = true
    end
  end
  # groups are viewable if they are owned by the DCC
  Organisation.where( name: "Digital Curation Centre").find_each do |dcc|
    if guidance_group.organisation.id == dcc.id
      viewable = true
    end
  end
  # groups are viewable if they are owned by a funder
  if guidance_group.organisation.organisation_type == OrganisationType.find_by( name: "Funder")
    viewable = true
  end

  return viewable
end

  ##
  # Returns a list of all guidance groups which a specified user can view
  # we define guidance groups viewable to a user by those owned by:
  #   the DCC
  #   a funder organisation
  #   an organisation, of which the user is a member
  #
  # @param user [User] a user object
  # @return [Array<GuidanceGroup>] a list of all "viewable" guidance groups to a user
def self.all_viewable(user)
  # first find all groups owned by the DCC
  dcc_groups = []
  Organisation.where( name: "Digital Curation Centre").find_each do |dcc|
    dcc_groups = dcc_groups + dcc.guidance_groups
    logger.info "another one"
  end

  # find all groups owned by  a Funder organisation
  funder_groups = []
  funders = OrganisationType.find_by( name: "Funder")
  logger.debug "found an org type? #{funders.organisations.first.name}"
  funders.organisations.each do |funder|
    funder_groups = funder_groups + funder.guidance_groups
    logger.info "iterating through funders"
  end
  # find all groups owned by any of the user's organisations
  organisation_groups = []
  user.organisations.each do |organisation|
    organisation_groups = organisation_groups + organisation.guidance_groups
  end
  # pass this list to the view with respond_with @all_viewable_groups
  all_viewable_groups = dcc_groups + funder_groups + organisation_groups
  all_viewable_groups = all_viewable_groups.uniq{|x| x.id}
  logger.debug "we finished it?"
  return all_viewable_groups
end




end
