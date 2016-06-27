# [+Project:+] DMPonline v4
# [+Description:+]
#   This class keeps the information organisations enter to support users when answering questions.
#   It always belongs to a guidance group class and it can be linked directly to a question or through one or more themes
# [+Created:+] 07/07/2014
# [+Copyright:+] Digital Curation Centre



class Guidance < ActiveRecord::Base
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


	#verifies if one guidance belongs to a org
	def in_group_belonging_to?(organisation_id)
		guidance_groups.each do |guidance_group|
			if guidance_group.organisation_id == organisation_id then
				return true
			end
		end
		return false
	end


	#all guidance that belong to an organisation
	def self.by_organisation(org_id)
		all_guidance = Guidance.all
		org_guidance = Array.new

		all_guidance.each do |guidance|
		   if guidance.in_group_belonging_to?(org_id) then
				org_guidance << guidance
		   end
		end

		return org_guidance

	end


	def get_guidance_group_templates? (guidance_group)
			templates = guidancegroups.where("guidance_group_id (?)", guidance_group.id).template
			return templates
	end

  def self.can_view(user, id)
    # we define guidances viewable to a user by those owned by a guidance group:
    #   owned by the DCC
    #   owned by a funder organisation
    #   owned by an organisation, of which the user is a member

    guidance = Guidance.find_by(id: id)
    viewable = false

    # guidances may belong to many guidance groups, so we check the above case for each
    guidance.guidance_groups.each do |guidance_group|

      # guidances are viewable if they are owned by any of the user's organisations
      user.organisations do |organisation|
        if guidance_group.organisation.id == organisation.id
          viewable = true
        end
      end

      # guidance groups are viewable if they are owned by the DCC
      if guidance_group.organisation.id == Organisation.find_by( name: "Digital Curation Centre").id
        viewable = true
      end

      # guidance groups are viewable if they are owned by a funder
      if guidance_group.organisation.organisation_type == OrganisationType.find_by( name: "Funder")
        viewable = true
      end
    end

    return viewable
  end

  def self.all_viewable(user)
    # we define vuiable guidances as those owned by a guidance group:
    #   owned by the DCC
    #   owned by a funder organisation
    #   owned by an organisation, of which the user is a member

    # first find all groups owned by the DCC
    dcc_groups = (Organisation.find_by name: "Digital Curation Centre").guidance_groups
    # find all groups owned by a Funder organisation
    funder_groups = []
    funders = OrganisationType.find_by( name: "Funder")
    funders.organisations.each do |funder|
      funder_groups = funder_groups + funder.guidance_groups
    end
    # find all groups owned by any of the user's organisations
    organisation_groups = []
    user.organisations.each do |organisation|
      organisation_groups = organisation_groups + organisation.guidance_groups
    end
    # find all guidances belonging to any of the viewable groups
    all_viewable_guidances = []
    all_viewable_groups = dcc_groups + funder_groups + organisation_groups
    all_viewable_groups.each do |group|
      all_viewable_guidances = all_viewable_guidances + group.guidances
    end
    # pass the list of viewable guidances to the view
    return all_viewable_guidances
  end

end
