class Plan < ActiveRecord::Base

	attr_accessible :locked, :project_id, :version_id, :version, :plan_sections, :as => [:default, :admin]

	A4_PAGE_HEIGHT = 297 #(in mm)
	A4_PAGE_WIDTH = 210 #(in mm)
	ROUNDING = 5 #round estimate up to nearest 5%
	FONT_HEIGHT_CONVERSION_FACTOR = 0.35278 #convert font point size to mm
	FONT_WIDTH_HEIGHT_RATIO = 0.4 #Assume glyph width averages 2/5 the height

	#associations between tables
	belongs_to :project
	belongs_to :version
	has_many :answers
	has_many :plan_sections

#	accepts_nested_attributes_for :project
	accepts_nested_attributes_for :answers
#	accepts_nested_attributes_for :version

	has_settings :export, class_name: 'Settings::Dmptemplate' do |s|
		s.key :export, defaults: Settings::Dmptemplate::DEFAULT_SETTINGS
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
		self.dmptemplate.settings(key)
	end

  ##
  # returns the template for this plan, or generates an empty template and returns that
  #
  # @return [Dmptemplate] the template associated with this plan
	def dmptemplate
		self.project.try(:dmptemplate) || Dmptemplate.new
	end

  ##
  # returns the title for this project as defined by the settings
  #
  # @return [String] the title for this project
	def title
		logger.debug "Title in settings: #{self.settings(:export).title}"
		if self.settings(:export).title == ""
      if !self.version.nil? && !self.version.phase.nil? && !self.version.phase.title? then
        return self.version.phase.title
      else
        return I18n.t('tool_title2')
			end
		else
			return self.settings(:export).title
		end
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
			question.options.each do |option|
				if option.is_default
					default_options << option
				end
			end
			answer.options = default_options
		end
		return answer
	end

  ##
  # returns all of the sections for this version of the plan, and for the project's organisation
  #
  # @return [Array<Section>,nil] either a list of sections, or nil if none were found
	def sections
		unless project.organisation.nil? then
			sections = version.global_sections + project.organisation.all_sections(version_id)
		else
			sections = version.global_sections
		end
		return sections.uniq.sort_by &:number
	end

  ##
  # returns the guidances associated with the project's organisation, for a specified question
  #
  # @params question [Question] the question to find guidance for
  # @return [Array<Guidance>] the list of guidances which pretain to the specified question
	def guidance_for_question(question)
		guidances = {}
		# If project org isn't nil, get guidance by theme from any "non-subset" groups belonging to project org
		unless project.organisation.nil? then
			project.organisation.guidance_groups.each do |group|
				if !group.optional_subset && (group.dmptemplates.pluck(:id).include?(project.dmptemplate_id) || group.dmptemplates.count == 0) then
					group.guidances.each do |guidance|
						guidance.themes.where("id IN (?)", question.theme_ids).each do |theme|
							guidances = self.add_guidance_to_array(guidances, group, theme, guidance)
						end
					end
				end
			end
		end
		# Get guidance by theme from any guidance groups selected on creation
		project.guidance_groups.each do |group|
			if group.dmptemplates.pluck(:id).include?(project.dmptemplate_id) || group.dmptemplates.count == 0 then
				group.guidances.each do |guidance|
					guidance.themes.where("id IN (?)", question.theme_ids).each do |theme|
						guidances = self.add_guidance_to_array(guidances, group, theme, guidance)
					end
				end
			end
    end
		# Get guidance by question where guidance group was selected on creation or if group is organisation default
		question.guidances.each do |guidance|
			guidance.guidance_groups.each do |group|
				if (group.organisation == project.organisation && !group.optional_subset) || project.guidance_groups.include?(group) then
					guidances = self.add_guidance_to_array(guidances, group, nil, guidance)
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
  # finds the specified warning for the plan's project's organisation
  #
  # @param option_id [Integer] the id to find the OptionWarning associated
  # @return [OptionWarning] the desired OptionWarning
	def warning(option_id)
		if project.organisation.nil?
			return nil
		else
			return project.organisation.warning(option_id)
		end
	end

  ##
  # determines if the plan is editable by the specified user
  # NOTE: This should be renamed to editable_by?
  #
  # @param user_id [Integer] the id for a user
  # @return [Boolean] true if user can edit the plan
	def editable_by(user_id)
		return project.editable_by(user_id)
	end

  ##
  # determines if the plan is readable by the specified user
  # NOTE: This shoudl be renamed to readable_by?
  #
  # @param user_id [Integer] the id for a user
  # @return [Boolean] true if the user can read the plan
	def readable_by(user_id)
		if project.nil?
			return false
		else
			return project.readable_by(user_id)
		end
	end

  ##
  # determines if the plan is administerable by the specified user
  # NOTE: This should be renamed to administerable_by?
  #
  # @param user_id [Integer] the id for the user
  # @return [Boolean] true if the user can administer the plan
	def administerable_by(user_id)
		return project.readable_by(user_id)
	end


  ##
  # defines and returns the status of the plan
  # status consists of a hash of the num_questions, num_answers, sections, questions, and spaced used.
  # For each section, it contains theid's of each of the questions
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

		space_used = height_of_text(self.project.title, 2, 2)

		sections.each do |s|
			space_used += height_of_text(s.title, 1, 1)
			section_questions = 0
			section_answers = 0
			status["sections"][s.id] = {}
			status["sections"][s.id]["questions"] = Array.new
			s.questions.each do |q|
				status["num_questions"] += 1
				section_questions += 1
				status["sections"][s.id]["questions"] << q.id
				status["questions"][q.id] = {}
				answer = answer(q.id, false)

				space_used += height_of_text(q.text) unless q.text == s.title
				space_used += height_of_text(answer.try(:text) || I18n.t('helpers.plan.export.pdf.question_not_answered'))

				if ! answer.nil? then
					status["questions"][q.id] = {
						"answer_id" => answer.id,
						"answer_created_at" => answer.created_at.to_i,
						"answer_text" => answer.text,
						"answer_option_ids" => answer.option_ids,
						"answered_by" => answer.user.name
					}
                    q_format = q.question_format
					status["num_answers"] += 1 if (q_format.title == I18n.t("helpers.checkbox") || q_format.title == I18n.t("helpers.multi_select_box") ||
                                        q_format.title == I18n.t("helpers.radio_buttons") || q_format.title == I18n.t("helpers.dropdown")) || answer.text.present?
					section_answers += 1
					#TODO: include selected options in space estimate
				else
					status["questions"][q.id] = {
						"answer_id" => nil,
						"answer_created_at" => nil,
						"answer_text" => nil,
						"answer_option_ids" => nil,
						"answered_by" => nil
					}
				end
 				status["sections"][s.id]["num_questions"] = section_questions
 				status["sections"][s.id]["num_answers"] = section_answers
			end
		end

		status['space_used'] = estimate_space_used(space_used)
		return status
	end


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

  ##
  # returns an array of hashes.  Each hash contains the question's id, the answer_id,
  # the answer_text, the answer_timestamp, and the answer_options
  #
  # @params section_id [Integer] the section to find answers of
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

private

  ##
	# Based on the height of the text gathered so far and the available vertical
	# space of the pdf, estimate a percentage of how much space has been used.
	# This is highly dependent on the layout in the pdf. A more accurate approach
	# would be to render the pdf and check how much space had been used, but that
	# could be very slow.
	# NOTE: This is only an estimate, rounded up to the nearest 5%; it is intended
	# for guidance when editing plan data, not to be 100% accurate.
  #
  # @params used_height [Integer] an estimate of the height used so far
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
  # @params text [String] the text to estimate size of
  # @params font_size_inc [Integer] the size of the font of the text, defaults to 0
  # @params vertical_margin [Integer] the top margin above the text, defaults to 0
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

end
