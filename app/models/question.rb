class Question < ActiveRecord::Base

  ##
  # Sort order: Number ASC
  default_scope { order(number: :asc) }

  ##
  # Associations
  has_many :answers, :dependent => :destroy
  has_many :question_options, :dependent => :destroy, :inverse_of => :question  # inverse_of needed for nester forms
  has_many :annotations, :dependent => :destroy
  has_and_belongs_to_many :themes, join_table: "questions_themes"
  belongs_to :section
  belongs_to :question_format

  ##
  # Nested Attributes
  # TODO: evaluate if we need this
  accepts_nested_attributes_for :answers, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true
  accepts_nested_attributes_for :question_options, :reject_if => lambda {|a| a[:text].blank? },  :allow_destroy => true
  accepts_nested_attributes_for :annotations,  :allow_destroy => true
  accepts_nested_attributes_for :themes

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :default_value, :dependency_id, :dependency_text, :guidance,:number, 
                  :annotation, :text, :section_id, :question_format_id, 
                  :question_options_attributes, :annotations_attributes, 
                  :option_comment_display, :theme_ids, :section, :question_format, 
                  :question_options, :annotations, :answers, :themes, 
                  :modifiable, :option_comment_display, :as => [:default, :admin]

  validates :text, :section, :number, presence: {message: _("can't be blank")}

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


  def option_based?
    format = self.question_format
    return format.option_based
  end

  def plan_answers(plan_id)
    return self.answers.to_a.select{|ans| ans.plan_id == plan_id}
  end

  ##
  # deep copy the given question and all it's associations
  #
  # @params [Question] question to be deep copied
  # @return [Question] the saved, copied question
  def self.deep_copy(question)
    question_copy = question.dup
    question_copy.save!
    question.question_options.each do |question_option|
      question_option_copy = QuestionOption.deep_copy(question_option)
      question_option_copy.question_id = question_copy.id
      question_option_copy.save!
    end
    question.annotations.each do |annotation|
      annotation_copy = Annotation.deep_copy(annotation)
      annotation_copy.question_id = question_copy.id
      annotation_copy.save!
    end
    question.themes.each do |theme|
      question_copy.themes << theme
    end
    return question_copy
  end

  ##
	# guidance for org
  #
  # @param org [Org] the org to find guidance for
  # @return [Hash{String => String}]
	def guidance_for_org(org)
    # pulls together guidance from various sources for question
    guidances = {}
    theme_ids = themes.collect{|t| t.id}
    if theme_ids.present?
      GuidanceGroup.includes(guidances: :themes).where(org_id: org.id).each do |group|
        group.guidances.each do |g|
          g.themes.each do |theme|
            if theme_ids.include? theme.id
              guidances["#{group.name} " + _('guidance on') + " #{theme.title}"] = g
            end
          end
        end
      end
    end

		return guidances
 	end

  ##
 	# get example answer belonging to the currents user for this question
  #
  # @param org_id [Integer] the id for the organisation
  # @return [String] the example answer for this question for the specified org
 	def get_example_answer(org_id)
 		example_answer = self.annotations.where(org_id: org_id).where(type: Annotation.types[:example_answer]).order(:created_at)
 		return example_answer.first
 	end

  def first_example_answer
    self.annotations.where(type: Annotation.types[:example_answer]).order(:created_at).first
  end
  
  ##
  # get guidance belonging to the current user's org for this question(need org 
  # to distinguish customizations)
  #
  # @param org_id [Integer] the id for the organisation
  # @return [String] the annotation guidance for this question for the specified org
  def get_guidance_annotation(org_id)
    guidance = self.annotations.where(org_id: org_id).where(type: Annotation.types[:guidance])
    return guidance.first
  end

end
