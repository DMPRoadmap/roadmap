class Plan < ActiveRecord::Base

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
                  :roles, :users, :org, :as => [:default, :admin]
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
    role = roles.where(user_id: user_id).first
    return role.present? && role.editor?
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
    role = roles.where(user_id: user_id).first
    return role.present?
	end

  ##
  # determines if the plan is administerable by the specified user
  #
  # @param user_id [Integer] the id for the user
  # @return [Boolean] true if the user can administer the plan
	def administerable_by?(user_id)
    user_id = user_id.id if user_id.is_a?(User)
    role = roles.where(user_id: user_id).first
    return role.present? && role.administrator?
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

# TODO: Guessing this isn't in use since it still refers to Project and Version
=begin
  ##
  # defines and returns the details for the plan
  # details consists of a hash of: project_title, phase_title, and for each section,
  # section: title, question text for each question, answer type and answer value
  #
  # @return [Details]
  def details
    details = {
      "project_title" => project.title,
      "phase_title" => version.phase.title,
      "sections" => {}
    }
    sections.sort_by(&:"number").each do |s|
      details["sections"][s.number] = {}
      details["sections"][s.number]["title"] = s.title
      details["sections"][s.number]["questions"] = {}
      s.questions.order("number").each do |q|
        details["sections"][s.number]["questions"][q.number] = {}
        details["sections"][s.number]["questions"][q.number]["question_text"] = q.text
        answer = answer(q.id, false)
        if ! answer.nil? then
                    q_format = q.question_format
          if (q_format.title == t("helpers.checkbox") || q_format.title == t("helpers.multi_select_box") ||
                                        q_format.title == t("helpers.radio_buttons") || q_format.title == t("helpers.dropdown")) then
            details["sections"][s.number]["questions"][q.number]["selections"] = {}
            answer.options.each do |o|
              details["sections"][s.number]["questions"][q.number]["selections"][o.number] = o.text
            end
          end
          details["sections"][s.number]["questions"][q.number]["answer_text"] = answer.text
        end
      end
    end
    return details
  end
=end

# TODO: commenting this old lock stuff out since PlanSection is gone and we wanted to get rid of it
=begin
  ##
  # determines wether or not a specified section of a plan is locked to a specified user and returns a status hash
  #
  # @param section_id [Integer] the setion to determine if locked
  # @param user_id [Integer] the user to determine if locked for
  # @return [Hash{String => Hash{String => Boolean, nil, String, Integer}}]
  def locked(section_id, user_id)
    plan_section = plan_sections.where("section_id = ? AND user_id != ? AND release_time > ?", section_id, user_id, Time.now).last
    if plan_section.nil? then
      status = {
        "locked" => false,
        "locked_by" => nil,
        "timestamp" => nil,
        "id" => nil
      }
    else
      status = {
        "locked" => true,
        "locked_by" => plan_section.user.name,
        "timestamp" => plan_section.updated_at,
        "id" => plan_section.id
      }
    end
  end

  ##
  # for each section, lock the section with the given user_id
  #
  # @param user_id [Integer] the id for the user who can use the sections
  def lock_all_sections(user_id)
    sections.each do |s|
      lock_section(s.id, user_id, 1800)
    end
  end

  ##
  # for each section, unlock the section
  #
  # @param user_id [Integer] the id for the user to unlock the sections for
  def unlock_all_sections(user_id)
    plan_sections.where(:user_id => user_id).order("created_at DESC").each do |lock|
      lock.delete
    end
  end

  ##
  # for each section, unlock the section
  # Not sure how this is different from unlock_all_sections
  #
  # @param user_id [Integer]
  def delete_recent_locks(user_id)
    plan_sections.where(:user_id => user_id).each do |lock|
      lock.delete
    end
  end

  ##
  # Locks the specified section to only be used by the specified user, for the number of secconds specified
  #
  # @param section_id [Integer] the id of the section to be locked
  # @param user_id [Integer] the id of the user who can use the section
  # @param release_time [Integer] the number of secconds the section will be locked for, defaults to 60
  # @return [Boolean] wether or not the section was locked
  def lock_section(section_id, user_id, release_time = 60)
    status = locked(section_id, user_id)
    if ! status["locked"] then
      plan_section = PlanSection.new
      plan_section.plan_id = id
      plan_section.section_id = section_id
      plan_section.release_time = Time.now + release_time.seconds
      plan_section.user_id = user_id
      plan_section.save
    elsif status["current_user"] then
      plan_section = PlanSection.find(status["id"])
      plan_section.release_time = Time.now + release_time.seconds
      plan_section.save
    else
      return false
    end
  end

  ##
  # unlocks the specified section for the specified user
  #
  # @param section_id [Integer] the id for the section to be unlocked
  # @param user_id [Integer] the id for the user for whom the section was previously locked
  # @return [Boolean] wether or not the lock was removed
  def unlock_section(section_id, user_id)
    plan_sections.where(:section_id => section_id, :user_id => user_id).order("created_at DESC").each do |lock|
      lock.delete
    end
  end
=end

# TODO: Commenting out because this method appears below as well so this one is overwritten
=begin
  ##
  # returns the time of either the latest answer to any question, or the latest update to the model
  #
  # @return [DateTime] the time at which the plan was last changed
  def latest_update
    if answers.any? then
      last_answered = answers.order("updated_at DESC").first.updated_at
      if last_answered > updated_at then
        return last_answered
      else
        return updated_at
      end
    else
      return updated_at
    end
  end
=end

# TODO: Guessing this isn't in use since it still refers to Project and Version
=begin
  ##
  # returns an array of hashes.  Each hash contains the question's id, the answer_id,
  # the answer_text, the answer_timestamp, and the answer_options
  #
  # @param section_id [Integer] the section to find answers of
  # @return [Array<Hash{String => nil,String,Integer,DateTime}]
  def section_answers(section_id)
    section = Section.find(section_id)
     section_questions = Array.new
     counter = 0
     section.questions.each do |q|
       section_questions[counter] = {}
       section_questions[counter]["id"] = q.id
       #section_questions[counter]["multiple_choice"] = q.multiple_choice
       q_answer = answer(q.id, false)
       if q_answer.nil? then
         section_questions[counter]["answer_id"] = nil
         if q.suggested_answers.find_by_organisation_id(project.organisation_id).nil? then
           section_questions[counter]["answer_text"] = ""
         else
           section_questions[counter]["answer_text"] = q.default_value
         end
         section_questions[counter]["answer_timestamp"] = nil
         section_questions[counter]["answer_options"] = Array.new
       else
         section_questions[counter]["answer_id"] = q_answer.id
         section_questions[counter]["answer_text"] = q_answer.text
         section_questions[counter]["answer_timestamp"] = q_answer.created_at
         section_questions[counter]["answer_options"] = q_answer.options.pluck(:id)
       end
       counter = counter + 1
     end
     return section_questions
  end
=end


  ##
  # assigns the passed user_id to the creater_role for the project
  # gives the user rights to read, edit, administrate, and defines them as creator
  #
  # @param user_id [Integer] the user to be given priveleges' id
  def assign_creator(user_id)
    user_id = user_id.id if user_id.is_a?(User)
    add_user(user_id, true, true, true)
  end
  


# TODO: commenting these out because they are overriden by private methods below, so this 
#       is unreachable
=begin
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
    available_height = page_height * self.template.settings(:export).max_pages

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
=end

# TODO: What are these used for? Should just be using self.org and self.org.funder? 
=begin
  ##
  # sets a new funder for the project
  # defaults to the first dmptemplate if the current template is nill and the funder has more than one dmptemplate
  #
  # @param new_funder_id [Integer] the id for a new funder
  # @return [Organisation] the new funder
  def funder_id=(new_funder_id)
    if new_funder_id != "" then
      new_funder = Org.find(new_funder_id);
      if new_funder.templates.count >= 1 && self.template.nil? then
        self.template = new_funder.templates.first
      end
    end
  end
=end

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

=begin
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
    org_table = Org.arel_table
    existing_org = Org.where(org_table[:name].matches(new_funder_name))
    if existing_org.nil?
      existing_org = Org.where(org_table[:abbreviation].matches(new_funder_name))
    end
    unless existing_org.empty?
      self.funder_id=existing_org.id
    end
  end

  ##
  # sets a new institution_id if there is no current organisation
  #
  # @param new_institution_id [Integer] the id for the new institution
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
#    if organisation.nil?
#      return nil
#    else
#      return organisation.root.id
#    end
     return template.org.id
  end

  ##
  # defines a new organisation_id for the project
  # but is confusingly labled unit_id
  #
  # @param new_unit_id [Integer]
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
=end

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

# TODO: ProjectGroup doesn't exist anymore so commenting these out
=begin
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
  # @param user_id [Integer] the user to check the priveleges of
  # @return [Boolean] true if the user created the project
  def created_by(user_id)
    user = project_groups.find_by_user_id(user_id)
    if (! user.nil?) && user.project_creator then
      return true
    else
      return false
    end
  end
=end

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
    self.roles.each do |role|
      if role.creator?
        return role.user
      end
    end
    return nil
  end

  ##
  # the time the project was last updated, formatted as a date
  #
  # @return [Date] last update as a date
  def last_edited
    self.latest_update.to_date
  end

# TODO: These next 2 reference defunct models so commenting out
=begin
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
=end
  
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

  def self.eager_load2(id)
    Plan.includes(
      [{template: [
                   {phases: {sections: {questions: [{answers: :notes}, :annotations, :question_format, :themes]}}},
                   {customizations: :org},
                   :org
                  ]},
       {plans_guidance_groups: {guidance_group: {guidances: :themes}}},
       {questions: :themes}
      ]).find(id)
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
      self.visibility = 3
    end
  end

end
