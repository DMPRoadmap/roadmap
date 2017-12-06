class Plan < ActiveRecord::Base
  include ConditionalUserMailer
  before_validation :set_creation_defaults

  ##
  # Associations
  belongs_to :template
  has_many :phases, through: :template
  has_many :sections, through: :phases
  has_many :questions, through: :sections
  has_many :themes, through: :questions
  has_many :answers, dependent: :destroy
  has_many :notes, through: :answers
  has_many :roles, dependent: :destroy
  has_many :users, through: :roles
  has_and_belongs_to_many :guidance_groups, join_table: :plans_guidance_groups

  accepts_nested_attributes_for :template
  has_many :exported_plans

  has_many :roles

# COMMENTED OUT THE DIRECT CONNECTION HERE TO Users to prevent assignment of users without an access_level specified (currently defaults to creator)
#  has_many :users, through: :roles


  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :locked, :project_id, :version_id, :version, :plan_sections,
                  :exported_plans, :project, :title, :template, :grant_number,
                  :identifier, :principal_investigator, :principal_investigator_identifier,
                  :description, :data_contact, :funder_name, :visibility, :exported_plans,
                  :roles, :users, :org, :data_contact_email, :data_contact_phone, :feedback_requested,
                  :principal_investigator_email, :as => [:default, :admin]
  accepts_nested_attributes_for :roles

  # public is a Ruby keyword so using publicly
  enum visibility: [:organisationally_visible, :publicly_visible, :is_test, :privately_visible]

  #TODO: work out why this messes up plan creation :
  #   briley: Removed reliance on :users, its really on :roles (shouldn't have a plan without at least a creator right?) It should be ok like this though now
#  validates :template, :title, presence: true

  ##
  # Constants
  A4_PAGE_HEIGHT = 297 #(in mm)
  A4_PAGE_WIDTH = 210 #(in mm)
  ROUNDING = 5 #round estimate up to nearest 5%
  FONT_HEIGHT_CONVERSION_FACTOR = 0.35278 #convert font point size to mm
  FONT_WIDTH_HEIGHT_RATIO = 0.4 #Assume glyph width averages 2/5 the height

  # Scope queries
  # Note that in ActiveRecord::Enum the mappings are exposed through a class method with the pluralized attribute name (e.g visibilities rather than visibility)
  scope :publicly_visible, -> { where(:visibility => visibilities[:publicly_visible]).order(:title => :asc) }

  # Retrieves any plan organisationally or publicly visible for a given org id
  scope :organisationally_or_publicly_visible, -> (user) {
    Plan.includes(:template)
      .where({
        visibility: [visibilities[:organisationally_visible], visibilities[:publicly_visible]],
        "templates.org_id": user.org_id})
      .where(['NOT EXISTS (SELECT 1 FROM roles WHERE plan_id = plans.id AND user_id = ?)', user.id])
      .order(:title => :asc)
  }

  # Retrieves plan, template, org, phases, sections and questions
  scope :overview, -> (id) {
    Plan.includes(:phases, :sections, :questions, template: [ :org ]).find(id)
  }
  ##
  # Settings for the template
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end
  alias_method :super_settings, :settings


  ##
  # Proxy through to the template settings (or defaults if this plan doesn't have
  # an associated template) if there are no settings stored for this plan.
  # `key` is required by rails-settings, so it's required here, too.
  #
  # @param key [Key] a key required by rails
  # @return [Settings] settings for this plan's template
  def settings(key)
    self_settings = self.super_settings(key)
    return self_settings if self_settings.value?
#    self.dmptemplate.settings(key)
    self.template.settings(key) unless self.template.nil?
  end

  ##
  # returns the template for this plan, or generates an empty template and returns that
  #
  # @return [Dmptemplate] the template associated with this plan
	def dmptemplate
		#self.project.try(:dmptemplate) || Dmptemplate.new
		self.template
	end



  def base_template
    base = nil
    t = self.template
    if t.customization_of.present?
      base = Template.where("dmptemplate_id = ? and created_at < ?", t.customization_of, self.created_at).order(version: :desc).first
    end
    return base
  end



  ##
  # returns the most recent answer to the given question id
  # optionally can create an answer if none exists
  #
  # @param qid [Integer] the id for the question to find the answer for
  # @param create_if_missing [Boolean] if true, will genereate a default answer to the question
  # @return [Answer,nil] the most recent answer to the question, or a new question with default value, or nil
	def answer(qid, create_if_missing = true)
  	answer = answers.where(:question_id => qid).order("created_at DESC").first
  	question = Question.find(qid)
		if answer.nil? && create_if_missing then
			answer = Answer.new
			answer.plan_id = id
			answer.question_id = qid
			answer.text = question.default_value
			default_options = Array.new
			question.question_options.each do |option|
				if option.is_default
					default_options << option
				end
			end
			answer.question_options = default_options
		end
		return answer
	end

# TODO: This just retrieves all of the guidance associated with the themes within the template
#       so why are we transferring it here to the plan?
  ##
  # returns all of the sections for this version of the plan, and for the project's organisation
  #
  # @return [Array<Section>,nil] either a list of sections, or nil if none were found
  def set_possible_guidance_groups
    # find all the themes in this plan
    # and get the guidance groups they belong to
    ggroups = []
    self.template.phases.each do |phase|
      phase.sections.each do |section|
        section.questions.each do |question|
          question.themes.each do |theme|
            theme.guidances.each do |guidance|
              ggroups << guidance.guidance_group if guidance.guidance_group.published
              # only show published guidance groups
            end
          end
        end
      end
    end

    self.guidance_groups = ggroups.uniq
  end

  ##
  # returns all of the possible guidance groups for the plan (all options to
  # be selected by the user to display)
  #
  # @return Array<Guidance>
  def get_guidance_group_options
    # find all the themes in this plan
    # and get the guidance groups they belong to
    ggroups = []
    Template.includes(phases: [sections: [questions: [themes: [guidances: [guidance_group: :org]]]]]).find(self.template_id).phases.each do |phase|
      phase.sections.each do |section|
        section.questions.each do |question|
          question.themes.each do |theme|
            theme.guidances.each do |guidance|
              ggroups << guidance.guidance_group if guidance.guidance_group.published
              # only show published guidance groups
            end
          end
        end
      end
    end
    return ggroups.uniq
  end
  
  ##
  # Sets up the plan for feedback:
  #  emails confirmation messages to owners
  #  emails org admins and org contact 
  #  adds org admins to plan with the 'reviewer' Role
  def request_feedback(user)
    Plan.transaction do
      begin
        val = Role.access_values_for(:reviewer, :commenter).min
        self.feedback_requested = true
    
        # Share the plan with each org admin as the reviewer role
        admins = user.org.org_admins
        admins.each do |admin|
          self.roles << Role.new(user: admin, access: val)
        end 

        if self.save!
          # Send an email confirmation to the owners and co-owners
          deliver_if(recipients: self.owner_and_coowners, key: 'users.feedback_requested') do |r|
            UserMailer.feedback_confirmation(r, self, user).deliver_now
          end
          # Send an email to all of the org admins as well as the Org's administrator email
          if user.org.contact_email.present? && !admins.collect{ |u| u.email }.include?(user.org.contact_email)
            admins << User.new(email: user.org.contact_email, firstname: user.org.contact_name)
          end
          deliver_if(recipients: admins, key: 'admins.feedback_requested') do |r|
            UserMailer.feedback_notification(r, self, user).deliver_now
          end
          true
        else
          false
        end
      rescue Exception => e
        Rails.logger.error e
        false
      end
    end
  end

  ##
  # Finalizes the feedback for the plan:
  #  emails confirmation messages to owners
  #  sets flag on plans.feedback_requested to false
  #  removes org admins from the 'reviewer' Role for the Plan
  def complete_feedback(org_admin)
    Plan.transaction do
      begin
        self.feedback_requested = false
        
        # Remove the org admins reviewer role from the plan 
        vals = Role.access_values_for(:reviewer)
        self.roles.delete(Role.where(plan: self, access: vals))
        
        if self.save!
          # Send an email confirmation to the owners and co-owners
          deliver_if(recipients: self.owner_and_coowners, key: 'users.feedback_provided') do |r|
            UserMailer.feedback_notification(r, self, org_admin).deliver_now
          end
          true
        else
          false
        end
      rescue Exception => e
        Rails.logger.error e
        false
      end
    end
  end

   ##
  # returns the guidances associated with the project's organisation, for a specified question
  #
  # @param question [Question] the question to find guidance for
  # @return array of hashes with orgname, themes and the guidance itself
  def guidance_for_question(question)
    guidances = []

    # add in the guidance for the template org
    unless self.template.org.nil? then
      self.template.org.guidance_groups.each do |group|
        group.guidances.each do |guidance|
          common_themes = guidance.themes.all & question.themes.all
          if common_themes.length > 0
            guidances << { orgname: self.template.org.name, theme: common_themes.join(','),  guidance: guidance }
          end
        end
      end
    end

    # add in the guidance for the user's org
    unless self.owner.nil?
      unless self.owner.org.nil? then
        self.owner.org.guidance_groups.each do |group|
          group.guidances.each do |guidance|
            common_themes = guidance.themes.all & question.themes.all
            if common_themes.length > 0
              guidances << { orgname: self.template.org.name, theme: common_themes.join(','),  guidance: guidance }
            end
          end
        end
      end
    end

    # Get guidance by theme from any guidance groups currently selected
    self.guidance_groups.each do |group|
      group.guidances.each do |guidance|
        common_themes = guidance.themes.all & question.themes.all
        if common_themes.length > 0
          guidances << { orgname: self.template.org.name, theme: common_themes.join(','),  guidance: guidance }
        end
      end
    end

    return guidances
  end




  ##
  # adds the given guidance to a hash indexed by a passed guidance group and theme
  #
  # @param guidance_array [{GuidanceGroup => {Theme => Array<Gudiance>}}] the passed hash of arrays of guidances.  Indexed by GuidanceGroup and Theme.
  # @param guidance_group [GuidanceGroup] the guidance_group index of the hash
  # @param theme [Theme] the theme object for the GuidanceGroup
  # @param guidance [Guidance] the guidance object to be appended to the correct section of the array
  # @return [{GuidanceGroup => {Theme => Array<Guidance>}}] the updated object which was passed in
  def add_guidance_to_array(guidance_array, guidance_group, theme, guidance)
    if guidance_array[guidance_group].nil? then
      guidance_array[guidance_group] = {}
    end
    if theme.nil? then
      if guidance_array[guidance_group]["no_theme"].nil? then
        guidance_array[guidance_group]["no_theme"] = []
      end
      if !guidance_array[guidance_group]["no_theme"].include?(guidance) then
        guidance_array[guidance_group]["no_theme"].push(guidance)
      end
    else
      if guidance_array[guidance_group][theme].nil? then
        guidance_array[guidance_group][theme] = []
      end
      if !guidance_array[guidance_group][theme].include?(guidance) then
        guidance_array[guidance_group][theme].push(guidance)
      end
    end
      return guidance_array
  end

  ##
  # determines if the plan is editable by the specified user
  #
  # @param user_id [Integer] the id for a user
  # @return [Boolean] true if user can edit the plan
	def editable_by?(user_id)
    user_id = user_id.id if user_id.is_a?(User)
    has_role(user_id, :editor)
	end

  ##
  # determines if the plan is readable by the specified user
  # TODO: introduce explicit readable rather than implicit
  # currently role with no flags = readable
  #
  # @param user_id [Integer] the id for a user
  # @return [Boolean] true if the user can read the plan
	def readable_by?(user_id)
    user_id = user_id.id if user_id.is_a?(User)
    has_role(user_id, :commenter)
	end

  ##
  # determines if the plan is administerable by the specified user
  #
  # @param user_id [Integer] the id for the user
  # @return [Boolean] true if the user can administer the plan
	def administerable_by?(user_id)
    user_id = user_id.id if user_id.is_a?(User)
    has_role(user_id, :administrator)
	end

  ##
  # determines if the plan is owned by the specified user
  #
  # @param user_id [Integer] the id for the user
  # @return [Boolean] true if the user can administer the plan
  def owned_by?(user_id)
    user_id = user_id.id if user_id.is_a?(User)
    has_role(user_id, :creator)
  end

  ##
  # determines if the plan is reviewable by the specified user
  #
  # @param user_id [Integer] the id for the user
  # @return [Boolean] true if the user can administer the plan
  def reviewable_by?(user_id)
    user_id = user_id.id if user_id.is_a?(User)
    has_role(user_id, :reviewer)
  end

  ##
  # determines whether or not the specified user has any rol on the plan
  #
  # @param user_id [Integer] the id for the user
  # @return [Boolean] true if the user has any rol
  def any_role?(user)
    user_id = user.id if user.is_a?(User)
    !self.roles.index{ |rol| rol.user_id == user_id }.nil?
  end

  ##
  # defines and returns the status of the plan
  # status consists of a hash of the num_questions, num_answers, sections, questions, and spaced used.
  # For each section, it contains the id's of each of the questions
  # for each question, it contains the answer_id, answer_created_by, answer_text, answer_options_id, aand answered_by
  #
  # @return [Status]

  def status
    status = {
      "num_questions" => 0,
      "num_answers" => 0,
      "sections" => {},
      "questions" => {},
      "space_used" => 0 # percentage of available space in pdf used
    }

    space_used = height_of_text(self.title, 2, 2)

    section_ids = sections.map {|s| s.id}

    # we retrieve this is 2 joins:
    #   1. sections and questions
    #   2. questions and answers
    # why? because Rails 4 doesn't have any sensible left outer join.
    # when we change to RAILS 5 it is meant to have so this can be fixed then

    records = Section.joins(questions: :question_format)
                     .select('sections.id as sectionid,
                              sections.title as stitle,
                              questions.id as questionid,
                              questions.text as questiontext,
                              question_formats.title as qformat')
                     .where("sections.id in (?) ", section_ids)
                     .to_a

    # extract question ids to get answers
    question_ids = records.map {|r| r.questionid}.uniq
    status["num_questions"] = question_ids.count

    arecords = Question.joins(answers: :user)
                       .select('questions.id as questionid,
                                answers.id as answerid,
                                answers.plan_id as plan_id,
                                answers.text as answertext,
                                answers.updated_at as updated,
                                users.email as username')
                       .where("questions.id in (?) and answers.plan_id = ?",question_ids, self.id)
                       .to_a

    # we want answerids to extract options later
    answer_ids = arecords.map {|r| r.answerid}.uniq
    status["num_answers"] = answer_ids.count

    # create map from questionid to answer structure
    qa_map = {}
    arecords.each do |rec|
      qa_map[rec.questionid] = {
        plan: rec.plan_id,
        id: rec.answerid,
        text: rec.answertext,
        updated: rec.updated,
        user: rec.username
      }
    end


    # build main status structure
    records.each do |rec|
      sid = rec.sectionid
      stitle = rec.stitle
      qid = rec.questionid
      qtext = rec.questiontext
      format = rec.qformat

      answer = nil
      if qa_map.has_key?(qid)
        answer = qa_map[qid]
      end

      aid = answer.nil? ? nil : answer[:id]
      atext = answer.nil? ? nil : answer[:text]
      updated = answer.nil? ? nil : answer[:updated]
      uname = answer.nil? ? nil : answer[:user]

      space_used += height_of_text(stitle, 1, 1)

      shash = status["sections"]
      if !shash.has_key?(sid)
        shash[sid] = {}
        shash[sid]["num_questions"] = 0
        shash[sid]["num_answers"] = 0
        shash[sid]["questions"] = Array.new
      end

      shash[sid]["questions"] << qid
      shash[sid]["num_questions"] += 1

      space_used += height_of_text(qtext) unless qtext == stitle
      if atext.present?
        space_used += height_of_text(atext)
      else
        space_used += height_of_text(_('Question not answered.'))
      end

      if answer.present? then
        shash[sid]["num_answers"] += 1
      end

      status["questions"][qid] = {
        "format" => format,
        "answer_id" => aid,
        "answer_updated_at" => updated.to_i,
        "answer_text" => atext,
        "answered_by" => uname
      }

    end

    records = Answer.joins(:question_options).select('answers.id as answerid, question_options.id as optid').where(id: answer_ids).to_a
    opt_hash = {}
    records.each do |rec|
      aid = rec.answerid
      optid = rec.optid
      if !opt_hash.has_key?(aid)
        opt_hash[aid] = Array.new
      end
      opt_hash[aid] << optid
    end

    status["questions"].each_key do |questionid|
      answerid = status["questions"][questionid]["answer_id"]
      status["questions"][questionid]["answer_option_ids"] = opt_hash[answerid]
    end

    status['space_used'] = estimate_space_used(space_used)

    return status
  end


  ##
  # assigns the passed user_id to the creater_role for the project
  # gives the user rights to read, edit, administrate, and defines them as creator
  #
  # @param user_id [Integer] the user to be given priveleges' id
  def assign_creator(user_id)
    user_id = user_id.id if user_id.is_a?(User)
    add_user(user_id, true, true, true)
  end

  ##
  # returns the funder id for the plan
  #
  # @return [Integer, nil] the id for the funder
  def funder_id
    if self.template.nil? then
      return nil
    end
    return self.template.org
  end

  ##
  # returns the funder organisation for the project or nil if none is specified
  #
  # @return [Organisation, nil] the funder for project, or nil if none exists
  def funder
    template = self.template
    if template.nil? then
      return nil
    end

    if template.customization_of
      return template.customization_of.org
    else
      return template.org
    end
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
  # the datetime for the latest update of this plan
  #
  # @return [DateTime] the time of latest update
  def latest_update
    latest_update = updated_at
    phases.each do |phase|
      if phase.updated_at > latest_update then
        latest_update = phase.updated_at
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
    vals = Role.access_values_for(:creator)
    User.joins(:roles).where('roles.plan_id = ? AND roles.access IN (?)', self.id, vals).first
  end

  ##
  # returns the shared roles of a plan, excluding the creator
  def shared
    role_values = Role.access_values_for(:commenter)
                      .concat(Role.access_values_for(:editor))
                      .concat(Role.access_values_for(:administrator)).uniq! - Role.access_values_for(:creator)
    Role.where(plan: self, access: role_values)
  end

  ##
  # the owner and co-owners of the project
  #
  # @return [Users]
  def owner_and_coowners
    vals = Role.access_values_for(:creator).concat(Role.access_values_for(:administrator))
    User.joins(:roles).where("roles.plan_id = ? AND roles.access IN (?)", self.id, vals)
  end

  ##
  # the time the project was last updated, formatted as a date
  #
  # @return [Date] last update as a date
  def last_edited
    self.latest_update.to_date
  end

  # Returns the number of answered questions from the entire plan
  def num_answered_questions
    n = 0
    self.sections.each do |s|
      n+= s.num_answered_questions(self.id)
    end
    return n
  end

  # Returns a section given its id or nil if does not exist for the current plan
  def get_section(section_id)
    self.sections.find { |s| s.id == section_id }
  end

  # Returns the number of questions for a plan. Note, this method becomes useful
  # for when sections and their questions are eager loaded so that avoids SQL queries.
  def num_questions
    n = 0
    self.sections.each do |s|
      n+= s.questions.size()
    end
    return n
  end
  # the following two methods are for eager loading. One gets used for the plan/show
  # page and the oter for the plan/edit. The difference is just that one pulls in more than
  # the other.
  # TODO: revisit this and work out for sure that maintaining the difference is worthwhile.
  # it may not be. Also make sure nether is doing more thanit needs to.
  #
  def self.eager_load(id)
    Plan.includes(
      [{template: [
                   {phases: {sections: {questions: :answers}}},
                   {customizations: :org}
                  ]},
       {plans_guidance_groups: {guidance_group: :guidances}}
      ]).find(id)
  end

  def self.load_for_phase(id, phase_id)
#    Plan.includes(
#      [template: [
#                   {phases: {sections: {questions: [{answers: :notes}, :annotations, :question_format, :themes]}}},
#                   {customizations: :org},
#                   :org
#                  ],
#       plans_guidance_groups: {guidance_group: {guidances: :themes}}
#      ]).where(id: id, phases: { id: phase_id }).first

    Plan.joins(:phases).where('plans.id = ? AND phases.id = ?', id, phase_id).includes(:template, :sections, :questions, :answers, :notes).first
  end

  # deep copy the given plan and all of it's associations
  #
  # @params [Plan] plan to be deep copied
  # @return [Plan] saved copied plan
  def self.deep_copy(plan)
    plan_copy = plan.dup
    plan_copy.title = "Copy of " + plan.title
    plan_copy.save!
    plan.answers.each do |answer|
      answer_copy = Answer.deep_copy(answer)
      answer_copy.plan_id = plan_copy.id
      answer_copy.save!
    end
    plan.guidance_groups.each do |guidance_group|
      if guidance_group.present?
        plan_copy.guidance_groups << GuidanceGroup.where(id: guidance_group.id).first
      end
    end
    return plan_copy
  end

  # Returns visibility message given a Symbol type visibility passed, otherwise nil
  def self.visibility_message(type)
    message = {
      :organisationally_visible => _('institutional'),
      :publicly_visible => _('public'),
      :is_test => _('test'),
      :privately_visible => _('private')
    }
    message[type]
  end

  # Determines whether or not visibility changes are permitted according to the
  # percentage of the plan answered in respect to a threshold defined at application.config
  def visibility_allowed?
    value=(self.num_answered_questions().to_f/self.num_questions()*100).round(2)
    !self.is_test? && value >= Rails.application.config.default_plan_percentage_answered
  end

  # Determines whether or not a question (given its id) exists for the self plan
  def question_exists?(question_id)
    Plan.joins(:questions).exists?(id: self.id, "questions.id": question_id)
  end

  private

  # Returns whether or not the user has the specified role for the plan
  def has_role(user_id, role_as_sym)
    if user_id.is_a?(Integer) && role_as_sym.is_a?(Symbol)
      vals = Role.access_values_for(role_as_sym)
      self.roles.where(user_id: user_id, access: vals).first.present?
    else
      false
    end
  end

  ##
  # adds a user to the project
  # if no flags are specified, the user is given read privleges
  #
  # @param user_id [Integer] the user to be given privleges
  # @param is_editor [Boolean] whether or not the user can edit the project
  # @param is_administrator [Boolean] whether or not the user can administrate the project
  # @param is_creator [Boolean] wheter or not the user created the project
  # @return [Array<ProjectGroup>]
  #
  # TODO: change this to specifying uniqueness of user/plan association and handle
  # that way
  #
  def add_user(user_id, is_editor = false, is_administrator = false, is_creator = false)
    Role.where(plan_id: self.id, user_id: user_id).each do |r|
      r.destroy
    end

    role = Role.new
    role.user_id = user_id
    role.plan_id = id

    # if you get assigned a role you can comment
    role.commenter= true

    # the rest of the roles are inclusing so creator => administrator => editor
    if is_creator
      role.creator =  true
      role.administrator = true
      role.editor = true
    end

    if is_administrator
      role.administrator = true
      role.editor = true
    end

    if is_editor
      role.editor = true
    end

    role.save

    # This is necessary because we're creating the associated record but not assigning it
    # to roles. Auto-saving like this may be confusing when coding upstream in a controller,
    # view or api. Should probably change this to:
    #    self.roles << role
    # and then let the save be called manually via:
    #    plan.save!
    #self.reload
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



  ##
	# Based on the height of the text gathered so far and the available vertical
	# space of the pdf, estimate a percentage of how much space has been used.
	# This is highly dependent on the layout in the pdf. A more accurate approach
	# would be to render the pdf and check how much space had been used, but that
	# could be very slow.
	# NOTE: This is only an estimate, rounded up to the nearest 5%; it is intended
	# for guidance when editing plan data, not to be 100% accurate.
  #
  # @param used_height [Integer] an estimate of the height used so far
  # @return [Integer] the estimate of space used of an A4 portrain
	def estimate_space_used(used_height)
		@formatting ||= self.settings(:export).formatting

		return 0 unless @formatting[:font_size] > 0

		margin_height    = @formatting[:margin][:top].to_i + @formatting[:margin][:bottom].to_i
		page_height      = A4_PAGE_HEIGHT - margin_height # 297mm for A4 portrait
		available_height = page_height * self.dmptemplate.settings(:export).max_pages

		percentage = (used_height / available_height) * 100
		(percentage / ROUNDING).ceil * ROUNDING # round up to nearest five
	end

  ##
	# Take a guess at the vertical height (in mm) of the given text based on the
	# font-size and left/right margins stored in the plan's settings.
	# This assumes a fixed-width for each glyph, which is obviously
	# incorrect for the font-face choices available; the idea is that
	# they'll hopefully average out to that in the long-run.
	# Allows for hinting different font sizes (offset from base via font_size_inc)
	# and vertical margins (i.e. for heading text)
  #
  # @param text [String] the text to estimate size of
  # @param font_size_inc [Integer] the size of the font of the text, defaults to 0
  # @param vertical_margin [Integer] the top margin above the text, defaults to 0
	def height_of_text(text, font_size_inc = 0, vertical_margin = 0)
		@formatting     ||= self.settings(:export).formatting
		@margin_width   ||= @formatting[:margin][:left].to_i + @formatting[:margin][:right].to_i
		@base_font_size ||= @formatting[:font_size]

		return 0 unless @base_font_size > 0

		font_height = FONT_HEIGHT_CONVERSION_FACTOR * (@base_font_size + font_size_inc)
		font_width  = font_height * FONT_WIDTH_HEIGHT_RATIO # Assume glyph width averages at 2/5s the height
		leading     = font_height / 2

		chars_in_line = (A4_PAGE_WIDTH - @margin_width) / font_width # 210mm for A4 portrait
		num_lines = (text.length / chars_in_line).ceil

		(num_lines * font_height) + vertical_margin + leading
	end

  # Initialize the title and dirty flags for new templates
  # --------------------------------------------------------
  def set_creation_defaults
    # Only run this before_validation because rails fires this before save/create
    if self.id.nil?
      self.title = "My plan (#{self.template.title})" if self.title.nil? && !self.template.nil?
    end
  end
end
