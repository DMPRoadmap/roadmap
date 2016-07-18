class Dmptemplate < ActiveRecord::Base
    
    attr_accessible :id, :organisation_id, :description, :published, :title, :user_id, :locale, 
                    :is_default, :guidance_group_ids, :as => [:default, :admin] 
  
    #associations between tables
    has_many :phases
    has_many :versions, :through => :phases
    has_many :sections, :through => :versions
    has_many :questions, :through => :sections
    has_many :projects
    
    #has_many :guidances                needs to be removed and checked
    
    belongs_to :organisation
      
	has_and_belongs_to_many :guidance_groups, join_table: "dmptemplates_guidance_groups"
	
    accepts_nested_attributes_for :guidance_groups
    accepts_nested_attributes_for :phases
    accepts_nested_attributes_for :organisation
    accepts_nested_attributes_for :projects

    
  has_settings :export, class_name: 'Settings::Dmptemplate' do |s|
    s.key :export, defaults: Settings::Dmptemplate::DEFAULT_SETTINGS
  end
    
  def to_s
    "#{title}"
  end
  
  def self.templates_org_type(ot)
    new_org_obejcts = OrganisationType.find_by_name(ot).organisations
    
    org_templates = Array.new
    new_org_obejcts.each do |neworg|
       org_templates += neworg.dmptemplates.where("published = ?", true)
    end
    
    return org_templates
  end 

	#returns all funders templates
	def self.funders_templates
		new_org_obejcts = OrganisationType.find_by_name(I18n.t("helpers.org_type.funder")).organisations
	  org_templates = Array.new
   	
   	new_org_obejcts.each do |neworg|
       	org_templates += neworg.dmptemplates
    end
    
    return org_templates	
	end
	
	
	#returns all institutional templates bellowing to the current user's org
	def self.own_institutional_templates(org_id)
		new_templates = self.where("organisation_id = ?", org_id)
		return new_templates
	end
	
	#returns an array with all funders and own institutional templates
	def self.funders_and_own_templates(org_id)
		funders_templates = self.funders_templates
	
        #verify if org type is not a funder
        current_org = Organisation.find(org_id)
        if current_org.organisation_type.name != I18n.t("helpers.org_type.funder") then 
            own_institutional_templates = self.own_institutional_templates(org_id)
		else
            own_institutional_templates = []
        end    
            
		templates_list = Array.new
		templates_list += own_institutional_templates
		templates_list += funders_templates
		templates_list = templates_list.sort_by { |f| f['title'].downcase }
				
		return templates_list
	end
	
	def org_type
		org_type = organisation.organisation_type.name
		return org_type
	end
	
	#verify if a template has customisation by current user's org
	def has_customisations?(org_id, temp)
		if temp.organisation_id != org_id then
			temp.phases.each do |phase|
				phase.versions.each do |version|
					version.sections.each do |section|
						return true if section.organisation_id == org_id 
											
					end	
				end
				return false 
			end
		else
			return false 	
		end	
	end
	
	
	# verify if there are any publish version for the template
	def has_published_versions?
		phases.each do |phase|
			return true if !phase.latest_published_version.nil?
		end
		return false 
	end

end
