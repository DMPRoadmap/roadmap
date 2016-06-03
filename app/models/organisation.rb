class Organisation < ActiveRecord::Base

	#associations between tables
	belongs_to :organisation_type
	has_many :guidance_groups
    has_many :dmptemplates
	has_many :sections
	has_many :users
	has_many :option_warnings
	has_many :suggested_answers
    
    has_many :user_org_roles
	
    belongs_to :parent, :class_name => 'Organisation'
	has_many :children, :class_name => 'Organisation', :foreign_key => 'parent_id'

	accepts_nested_attributes_for :organisation_type
	accepts_nested_attributes_for :dmptemplates

	#attr_accessible :abbreviation, :banner_text, :description, :domain, :logo_file_name, :name, :stylesheet_file_id, :target_url, :organisation_type_id, :wayfless_entity, :parent_id, :sort_name

	def to_s
		name
	end

	def short_name
		if abbreviation.nil? then
			return name
		else
			return abbreviation
		end
	end

	#retrieves info off a child org
	def self.orgs_with_parent_of_type(org_type)
		parents = OrganisationType.find_by_name(org_type).organisations
		children = Array.new
		parents.each do |parent|
		  	children += parent.children
		end
		return children
	end


	def self.other_organisations
		org_types = [I18n.t('helpers.org_type.organisation')]
		organisations_list = []
		org_types.each do |ot|
			new_org_obejct = OrganisationType.find_by_name(ot)

			org_with_guidance = GuidanceGroup.joins(new_org_obejct.organisations)

			organisations_list = organisations_list + org_with_guidance
		end
		return organisations_list
	end

	def all_sections(version_id)
		if parent.nil?
			secs = sections.where("version_id = ?", version_id)
			if secs.nil? then
				secs = Array.new
			end
			return secs
		else
			return sections.where("version_id = ? ", version_id).all + parent.all_sections(version_id)
		end
	end

	def all_guidance_groups
		ggs = guidance_groups
		children.each do |c|
			ggs = ggs + c.all_guidance_groups
		end
		return ggs
	end

	def root
		if parent.nil?
			return self
		else
			return parent.root
		end
	end

	def warning(option_id)
		warning = option_warnings.find_by_option_id(option_id)
		if warning.nil? && !parent.nil? then
			return parent.warning(option_id)
		else
			return warning
		end
	end

	def published_templates
		return dmptemplates.where("published = ?", 1)
	end


end
