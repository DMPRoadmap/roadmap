class Option < ActiveRecord::Base
  
  #associations between tables
  belongs_to :question
    
  has_many :option_warnings, :dependent => :destroy
  
  has_and_belongs_to_many :answers, join_table: "answers_options"
    
# TODO: REMOVE AND HANDLE ATTRIBUTE SECURITY IN THE CONTROLLER!
  attr_accessible :text, :question_id, :is_default, :number, :question,
                  :option_warnings, :answers, :as => [:default, :admin]
  
  validates :question, :text, :number, presence: true
  
  def to_s
    "#{text}"
  end
end