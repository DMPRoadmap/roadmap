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
  attr_accessible :default_value, :dependency_id, :dependency_text, :guidance,:number, 
                  :suggested_answer, :text, :section_id, :question_format_id, 
                  :question_options_attributes, :suggested_answers_attributes, 
                  :option_comment_display, :theme_ids, :section, :question_format, 
                  :question_options, :suggested_answers, :answers, :themes, 
                  :modifiable, :option_comment_display, :as => [:default, :admin]

  validates :text, :section, :number, presence: true


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

# TODO: Commented this amoeba cloning gem definition out to see if its even used. The
#       amoeba documentations uses [object].amoeba_dup to clone the object, but that
#       command does not exist in the codebase

#  amoeba do
#    include_association :options
#    include_association :suggested_answers
#    clone [:themes]
#  end

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
