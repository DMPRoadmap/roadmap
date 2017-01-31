class Question < ActiveRecord::Base

  ##
  # Associations
  has_many :answers, :dependent => :destroy
  has_many :question_options, :dependent => :destroy
  has_many :suggested_answers, :dependent => :destroy
  has_and_belongs_to_many :themes, join_table: "questions_themes"
  belongs_to :section
  belongs_to :question_format

  ##
  # Nested Attributes
  # TODO: evaluate if we need this
  accepts_nested_attributes_for :answers, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true
  accepts_nested_attributes_for :question_options, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true
  accepts_nested_attributes_for :suggested_answers,  :allow_destroy => true
  accepts_nested_attributes_for :themes

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :default_value, :dependency_id, :dependency_text, :guidance,:number, :suggested_answer, :text, :section_id, :question_format_id, :question_options_attributes, :suggested_answers_attributes, :option_comment_display, :theme_ids, :as => [:default, :admin]



  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?



  ##
  # returns the text from the question
  #
  # @return [String] question's text
	def to_s
    "#{text}"
  end

  def select_text
    cleantext = text.gsub(/<[^<]+>/, '')
    if cleantext.length > 120
      cleantext = cleantext.slice(0,120)
    end
    cleantext
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
	def guidance_for_question(question, org)
    # pulls together guidance from various sources for question
    guidances = {}
    theme_ids = question.theme_ids
    if theme_ids.present?
      GuidanceGroup.where(org_id: org.id).each do |group|
        group.guidances.each do |g|
          g.themes.where("id IN (?)", theme_ids).each do |gg|
            guidances["#{group.name} " + I18n.t('admin.guidance_lowercase_on') + " #{gg.title}"] = g
          end
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
 		suggested_answer = suggested_answers.find_by(org_id: org_id)
 		return suggested_answer
 	end

end
