class NewQuestion < ActiveRecord::Base
  belongs_to :new_section
  has_one :new_answer
  has_one :note
  has_many :question_options
  belongs_to :question_format
  has_and_belongs_to_many :themes, join_table: :new_questions_themes
end
