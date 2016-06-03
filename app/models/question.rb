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
  accepts_nested_attributes_for :section
  accepts_nested_attributes_for :question_format
  accepts_nested_attributes_for :options, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true
  accepts_nested_attributes_for :suggested_answers,  :allow_destroy => true
  accepts_nested_attributes_for :themes
  
  attr_accessible :theme_ids, :as => [:default, :admin]

  attr_accessible :default_value, :dependency_id, :dependency_text, :guidance,:number, :parent_id, :suggested_answer, :text, :section_id,:question_format_id,:options_attributes,:suggested_answers_attributes, :option_comment_display, :as => [:default, :admin]

	def to_s
        "#{text}"
    end

    amoeba do
        include_field :options
        include_field :suggested_answers
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

	# guidance for question in the org admin
	def guidance_for_question(question, org_admin)
        # pulls together guidance from various sources for question
        guidances = {}
        theme_ids = question.theme_ids

        GuidanceGroup.where("organisation_id = ?", org_admin.id).each do |group|
            group.guidances.each do |g|
                g.themes.where("id IN (?)", theme_ids).each do |gg|
                   guidances["#{group.name} guidance on #{gg.title}"] = g
                end
            end
        end

	  	# Guidance link to directly to a question
        question.guidances.each do |g_by_q|
            g_by_q.guidance_groups.each do |group|
                if group.organisation == org_admin
                    guidances["#{group.name} guidance for this question"] = g_by_q
                end
            end
	  	end

		return guidances
 	end

    
    
    
    
 	#get suggested answer belonging to the currents user for this question
 	def get_suggested_answer(org_id)
 		suggested_answer = suggested_answers.find_by_organisation_id(org_id)
 		return suggested_answer
 	end



end
