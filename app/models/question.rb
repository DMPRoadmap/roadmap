class Question < ActiveRecord::Base

  #associations between tables
  has_many :answers, :dependent => :destroy
  has_many :options, :dependent => :destroy
  has_many :suggested_answers, :dependent => :destroy
  has_many :guidances
  has_many :comments
  
  has_and_belongs_to_many :themes, join_table: "questions_themes"  
  

  belongs_to :section
  belongs_to :question_format

  accepts_nested_attributes_for :answers, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true
#  accepts_nested_attributes_for :section
#  accepts_nested_attributes_for :question_format
  accepts_nested_attributes_for :options, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true
  accepts_nested_attributes_for :suggested_answers,  :allow_destroy => true
  accepts_nested_attributes_for :themes

  attr_accessible :default_value, :dependency_id, :dependency_text, :guidance,:number, :parent_id, :suggested_answer, :text, :section_id,:question_format_id,:options_attributes, :suggested_answers_attributes, :option_comment_display, :theme_ids, :as => [:default, :admin]

  ##
  # returns the text from the question
  #
  # @return [String] question's text
	def to_s
    "#{text}"
  end

  amoeba do
    include_association :options
    include_association :suggested_answers
    clone [:themes]
  end

	#def question_type?
	#	type_label = {}
	#	if self.is_text_field?
	#	  type_label = 'Text field'
	#	elsif self.multiple_choice?
	#		type_label = 'Multiple choice'
	#	else
	#		type_label = 'Text area'
	#	end
	#	return type_label
	#end

  ##
  # for each question theme, appends them separated by comas
  # shouldnt have a ? after the method name
  #
  # @return [Hash{String=> String}]
	def question_themes?
		themes_label = {}
		i = 1
		themes_quest = self.themes

		themes_quest.each do |tt|
			themes_label = tt.title

			if themes_quest.count > i then
				themes_label +=	','
				i +=1
			end
		end

		return themes_label
	end

  ##
	# guidance for question in the org admin
  #
  # @param question [Question] the question to find guidance for
  # @param org_admin [Organisation] the organisation to find guidance for
  # @return [Hash{String => String}]
	def guidance_for_question(question, org_admin)
        # pulls together guidance from various sources for question
        guidances = {}
        theme_ids = question.theme_ids

        GuidanceGroup.where("organisation_id = ?", org_admin.id).each do |group|
            group.guidances.each do |g|
                g.themes.where("id IN (?)", theme_ids).each do |gg|
                   guidances["#{group.name} " + I18n.t('admin.guidance_lowercase_on') + " #{gg.title}"] = g
                end
            end
        end
	  	# Guidance link to directly to a question
        question.guidances.each do |g_by_q|
            g_by_q.guidance_groups.each do |group|
                if group.organisation == org_admin
                    guidances["#{group.name} " + I18n.t('admin.guidance_lowercase')] = g_by_q
                end
            end
	  	end
		return guidances
 	end

  ##
 	# get suggested answer belonging to the currents user for this question
  #
  # @param org_id [Integer] the id for the organisation
  # @return [String] the suggested_answer for this question for the specified organisation
 	def get_suggested_answer(org_id)
 		suggested_answer = suggested_answers.find_by_organisation_id(org_id)
 		return suggested_answer
 	end

end
