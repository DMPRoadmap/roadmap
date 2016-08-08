class Project < ActiveRecord::Base
  include GlobalHelpers

	extend FriendlyId

	attr_accessible :dmptemplate_id, :title, :organisation_id, :unit_id, :guidance_group_ids, 
                  :project_group_ids, :funder_id, :institution_id, :grant_number, :identifier, 
                  :description, :principal_investigator, :principal_investigator_identifier, 
                  :data_contact, :funder_name, :as => [:default, :admin]

	#associations between tables
	belongs_to :dmptemplate
	belongs_to :organisation
	has_many :plans
	has_many :project_groups, :dependent => :destroy
	has_and_belongs_to_many :guidance_groups, join_table: "project_guidance"

	friendly_id :title, use: [:slugged, :history, :finders]

  ##
  # returns the title of the project
  #
  # @return [String] the project's title
	def to_s
		"#{title}"
	end

	after_create :create_plans

  ##
  # sets a new funder for the project
  # defaults to the first dmptemplate if the current template is nill and the funder has more than one dmptemplate
  #
  # @param new_funder_id [Integer] the id for a new funder
  # @return [Organisation] the new funder
	def funder_id=(new_funder_id)
		if new_funder_id != "" then
			new_funder = Organisation.find(new_funder_id);
			if new_funder.dmptemplates.count >= 1 && self.dmptemplate.nil? then
				self.dmptemplate = new_funder.dmptemplates.first
      end
		end
	end

  ##
  # returns the funder id for the project
  #
  # @return [Integer, nil] the id for the funder
	def funder_id
		if self.dmptemplate.nil? then
			return nil
		end
		template_org = self.dmptemplate.organisation
		if template_org.organisation_type.name == constant("organisation_types.funder").downcase
			return template_org.id
		else
			return nil
		end
	end

  ##
  # returns the funder organisation for the project or nil if none is specified
  #
  # @return [Organisation, nil] the funder for project, or nil if none exists
	def funder
		if self.dmptemplate.nil? then
			return nil
		end
		template_org = self.dmptemplate.organisation
		if template_org.organisation_type.name == constant("organisation_types.funder").downcase
			return template_org
		else
			return nil
		end
	end

  ##
  # returns the name of the funder for the project
  #
  # @return [String] the name fo the funder for the project
	def funder_name
		if self.funder.nil?
			return read_attribute(:funder_name)
		else
			return self.funder.name
		end
	end

  ##
  # defines a new funder_name for the project.
  #
  # @param new_funder_name [String] the string name of the new funder
  # @return [Integer, nil] the org_id of the new funder
	def funder_name=(new_funder_name)
		write_attribute(:funder_name, new_funder_name)
		org_table = Organisation.arel_table
		existing_org = Organisation.where(org_table[:name].matches(new_funder_name))
		if existing_org.nil?
			existing_org = Organisation.where(org_table[:abbreviation].matches(new_funder_name))
		end
		unless existing_org.empty?
			self.funder_id=existing_org.id
		end
	end

  ##
  # sets a new institution_id if there is no current organisation
  #
  # @params new_institution_id [Integer] the id for the new institution
  # @return [Integer, Bool] false if an organisation exists, or the id of the set org if a new organisation is set
	def institution_id=(new_institution_id)
		if organisation.nil? then
			self.organisation_id = new_institution_id
		end
	end

  ##
  # returns the organisation which is root over the owning organisation
  #
  # @return [Integer, nil] the organisation_id or nil
	def institution_id
		if organisation.nil?
			return nil
		else
			return organisation.root.id
		end
	end

  ##
  # defines a new organisation_id for the project
  # but is confusingly labled unit_id
  #
  # @params new_unit_id [Integer]
  # @return [Integer, Boolean] the new organisation ID or false if no unit_id was passed
	def unit_id=(new_unit_id)
		unless new_unit_id.nil? ||new_unit_id == ""
			self.organisation_id = new_unit_id
		end
	end

  ##
  # returns the organisation_id or nil
  # again seems redundant
  #
  # @return [nil, Integer] nil if no organisation, or the id if there is an organisation specified
	def unit_id
		if organisation.nil? || organisation.parent_id.nil?
			return nil
		else
			return organisation_id
		end
	end

  ##
  # assigns the passed user_id to the creater_role for the project
  # gives the user rights to read, edit, administrate, and defines them as creator
  #
  # @param user_id [Integer] the user to be given priveleges' id
	def assign_creator(user_id)
		add_user(user_id, true, true, true)
	end

  ##
  # assigns the passed user_id as an editor for the project
  # gives the user rights to read and edit
  #
  # @param user_id [Integer] the user to be given priveleges' id
	def assign_editor(user_id)
		add_user(user_id, true)
	end

  ##
  # assigns the passed user_id as a reader for the project
  # gives the user rights to read
  #
  # @param user_id [Integer] the user to be given priveleges' id
	def assign_reader(user_id)
		add_user(user_id)
	end

  ##
  # assigns the passed user_id as an administrator for the project
  # gives the user rights to read, adit, and administrate the project
  #
  # @param user_id [Integer] the user to be given priveleges' id
	def assign_administrator(user_id)
		add_user(user_id, true, true)
	end

  ##
  # whether or not the current plan is administrable by the user
  #
  # @param user_id [Integer] the user to check if has privleges
  # @return [Boolean] true if user can administer project, false otherwise
	def administerable_by(user_id)
		user = project_groups.find_by_user_id(user_id)
		if (! user.nil?) && user.project_administrator then
			return true
		else
			return false
		end
	end

  ##
  # whether or not the current plan is editable by the user
  #
  # @param user_id [Integer] the user to check if has privleges
  # @return [Boolean] true if user can edit project, false otherwise
	def editable_by(user_id)
		user = project_groups.find_by_user_id(user_id)
		if (! user.nil?) && user.project_editor then
			return true
		else
			return false
		end
	end

  ##
  # whether or not the current plan is readable by the user
  # should be renamed to readable_by?
  #
  # @param user_id [Integer] the user to check if has privleges
  # @return [Boolean] true if user can read project, false otherwise
	def readable_by(user_id)
		user = project_groups.find_by_user_id(user_id)
		if (! user.nil?) then
			return true
		else
			return false
		end
	end

  ##
  # returns the projects which the user can atleast read
  #
  # @param user_id [Integer] the user to lookup projects for
  # @return [Array<Project>] list of all projects the user can atleast read
	def self.projects_for_user(user_id)
		projects = Array.new
		groups = ProjectGroup.where("user_id = ?", user_id)
		unless groups.nil? then
			groups.each do |group|
				unless group.project.nil? then
					projects << group.project
				end
			end
		end
		return projects
	end

  ##
  # whether or not the specified user_id created this project
  # should be renamed to created_by?
  #
  # @params user_id [Integer] the user to check the priveleges of
  # @return [Boolean] true if the user created the project
	def created_by(user_id)
		user = project_groups.find_by_user_id(user_id)
		if (! user.nil?) && user.project_creator then
			return true
		else
			return false
		end
	end

  ##
  # the datetime for the latest update of this project, or any plan it owns
  #
  # @return [DateTime] the time of latest update
	def latest_update
		latest_update = updated_at
		plans.each do |plan|
			if plan.latest_update > latest_update then
				latest_update = plan.latest_update
			end
		end
		return latest_update
	end

	# Getters to match 'My plans' columns

  ##
  # the title of the project
  #
  # @return [String] the title of the project
	def name
		self.title
	end

  ##
  # the owner of the project
  #
  # @return [User] the creater of the project
	def owner
		self.project_groups.find_by_project_creator(true).try(:user)
	end

  ##
  # the time the project was last updated, formatted as a date
  #
  # @return [Date] last update as a date
	def last_edited
		self.latest_update.to_date
	end

  ##
  # whether or not the plan is shared with anybody
  #
  # @return [Boolean] true if the project has been shared
	def shared?
		self.project_groups.count > 1
	end

	alias_method :shared, :shared?

  ##
  # the organisation who owns the project
  #
  # @return [Dmptemplate,Organisation,String] the template, it's owner, or it's owner's abreviation
	def template_owner
		self.dmptemplate.try(:organisation).try(:abbreviation)
	end

	private

  ##
  # adds a user to the project
  # if no flags are specified, the user is given read privleges
  #
  # @param user_id [Integer] the user to be given privleges
  # @param is_editor [Boolean] whether or not the user can edit the project
  # @param is_administrator [Boolean] whether or not the user can administrate the project
  # @param is_creator [Boolean] wheter or not the user created the project
  # @return [Array<ProjectGroup>]
	def add_user(user_id, is_editor = false, is_administrator = false, is_creator = false)
		group = ProjectGroup.new
		group.user_id = user_id
		group.project_creator = is_creator
		group.project_editor = is_editor
		group.project_administrator = is_administrator
		project_groups << group
	end

  ##
  # creates a plan for each phase in the dmptemplate associated with this project
  # unless the phase is unpublished, it creates a new plan, and a new version of the plan and adds them to the project's plans
  #
  # @return [Array<Plan>]
	def create_plans
		dmptemplate.phases.each do |phase|
			latest_published_version = phase.latest_published_version
			unless latest_published_version.nil?
				new_plan = Plan.new
				new_plan.version = latest_published_version
				plans << new_plan
			end
		end
	end
end
